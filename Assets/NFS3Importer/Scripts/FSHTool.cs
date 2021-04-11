using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using NFS3Importer.Utility;
using UnityEngine;

/// <summary>
/// This tool was originally written by Denis Auroux.
/// ** New generation FSH/QFS decompressor/compressor
/// ** Version 1.22 - copyright (c) Denis Auroux 1998-2002
/// ** auroux@math.polytechnique.fr
/// ** http://www.math.polytechnique.fr/cmat/auroux/nfs/
/// ** http://auroux.free.fr/nfs/
/// Translated into C# by David Martin
/// </summary>
namespace NFS3Importer
{
    public class FSHTool
    {

        private const string HEXDIGITS = "0123456789ABCDEF";
        private bool iscompr;
        private int inlen;

        private Dictionary<string, byte[]> bmps, alphas;
        private byte[] alpha8;
        private string fshindex;

        public FSHTool(string file)
        {
            byte[] tmpbuf;
            byte[] inbuf = File.ReadAllBytes(file);
            FileInfo fi = new FileInfo(file);
            // FSH and QFS files are not as big^^
            inlen = (int)fi.Length;
            if (inlen < 4) { Debug.LogError("Truncated file ?"); }
            iscompr = false;
            if (((inbuf[0] & 0xfe) == 0x10) && (inbuf[1] == 0xfb))
            {
                /* this is a compressed QFS file */
                iscompr = true;
                tmpbuf = uncompressData(inbuf, 0, ref inlen);
                inbuf = tmpbuf;
            }

            FileReader fr = new FileReader(inbuf);
            if (fr.readString(4).Equals("SHPI"))
            {
                /* this is a FSH file */
                fsh2Bmp(file, inbuf, out bmps, out alphas, out alpha8, out fshindex);
            }

        }

        public Dictionary<string, byte[]> GetBMPs()
        {
            return bmps;
        }

        public Dictionary<string, byte[]> GetAlphas()
        {
            return alphas;
        }

        public byte[] GetAlpha8()
        {
            return alpha8;
        }

        public string GetFSHIndex()
        {
            return fshindex;
        }

        private void fsh2Bmp(string fshname, byte[] inbuf, out Dictionary<string, byte[]> bmps, out Dictionary<string, byte[]> alphas, out byte[] alpha8, out string fshindex)
        {
            List<byte> bmp = null, alpha = null;
            alpha8 = null;
            FileReader sbuf = null;
            int nbmp = 0, i = 0, j = 0, k = 0, l = 0, m = 0, n = 0, globpallen = 0, offs = 0, nxoffs = 0, paloffs = 0, auxoffs = 0, hasglobpal = 0, nattach = 0;
            int locpallen = 0, bmpw = 0, curoffs = 0, compressed = 0;
            bool isbmp = false;
            int numscales = 0, packed_mbp = 0, mbp_len = 0, mbpp_len = 0;
            int[] globpal = new int[256];
            int[] locpal = new int[256];
            FSHHDR fshhdr = null;
            StructArray<BMPDIR> dir = null;
            ENTRYHDR hdr = null, auxhdr = null, palhdr = null;
            BMPHEAD bmphdr = null;
            StringBuilder pad, log;
            ArrayPtr<byte> ptr = null;
            byte[] bmpptr, tmp = null;
            byte value = 0;
            ushort us1 = 0, us2 = 0;
            string alphafile = "alpha.bmp";
            string bmpfile = "bmp.bmp";

            FileReader fr = new FileReader(inbuf);

            bmps = new Dictionary<string, byte[]>();
            alphas = new Dictionary<string, byte[]>();
            fshindex = null;

            fshhdr = new FSHHDR(inbuf, 0);
            dir = new StructArray<BMPDIR>(inbuf, 16);

            pad = new StringBuilder();
            log = new StringBuilder();

            log.AppendLine("FSHTool generated file -- be very careful when editing");
            log.AppendLine(fshname);

            if (iscompr)
            {
                log.AppendLine("QFS");
            }
            else
            {
                log.AppendLine("FSH");
            }

            nbmp = fshhdr.nbmp;

            log.AppendFormat("SHPI {0} objects, tag {1}\n", nbmp, quotify(fshhdr.dirId, 0, 4));

            if (inlen < 200000) i = 4 * inlen;
            else if (inlen < 500000) i = 2 * inlen;
            else i = inlen + 500000;

            log.AppendFormat("BUFSZ {0}\n", i);

            /* look for a global palette */
            j = -1;
            hasglobpal = 0;
            for (i = 0; i < nbmp && hasglobpal == 0; i++)
            {
                hdr = new ENTRYHDR(inbuf, dir[i].ofs);
                k = hdr.code & 0xff;
                if ((k == 0x22) || (k == 0x24) || (k == 0x2D) || (k == 0x2A) || (k == 0x29)) j = i;
                if (dir[i].name.Equals("!pal")) hasglobpal = 1;
            }

            hasglobpal = j;

            if (hasglobpal >= 0)
            {
                globpal = makepal(inbuf, dir[hasglobpal].ofs, ref globpallen);
                log.AppendFormat("GLOBPAL {0:D4}.BIN\n", hasglobpal);
            }
            else
            {
                log.AppendLine("NOGLOBPAL");
            }

            j = fshhdr.filesize;
            for (i = 0; i < nbmp; i++)
            {
                if (dir[i].ofs < j) j = dir[i].ofs;
            }
            if (j > (16 + 8 * nbmp))
            {
                log.AppendFormat("!PAD {0} ", j - 16 - 8 * nbmp);
                fr.setCurrPos(16 + 8 * nbmp);
                tmp = fr.readBytes(j - 16 - 8 * nbmp);
                log.AppendLine(hexify(tmp, 0, tmp.Length).GetUTF8String());
            }

            /* main loop */

            for (i = 0; i < nbmp; i++)
            {
                offs = dir[i].ofs;
                /* offset of the following entry ? */
                nxoffs = fshhdr.filesize;
                for (j = 0; j < nbmp; j++)
                {
                    if ((dir[j].ofs < nxoffs) && (dir[j].ofs > offs))
                    {
                        nxoffs = dir[j].ofs;
                    }
                }

                /* understand the attachment structure */
                hdr = new ENTRYHDR(inbuf, offs);
                j = hdr.code & 0x7f;

                isbmp = (j == 0x78) || (j == 0x7B) || (j == 0x7D) || (j == 0x7E) || (j == 0x7F) || (j == 0x6D) || (j == 0x61) || (j == 0x60);
                compressed = (hdr.code & 0x80);

                if (isbmp)
                {
                    auxhdr = hdr; auxoffs = offs; nattach = 0; palhdr = null; paloffs = 0;
                    while ((auxhdr.code >> 8) > 0)
                    {
                        nattach++;
                        auxoffs += (auxhdr.code >> 8);
                        if (auxoffs > nxoffs)
                        {
                            Debug.LogError("ERROR: incorrect attachment structure !");
                        }
                        if (auxoffs == nxoffs) break;
                        auxhdr = new ENTRYHDR(inbuf, auxoffs);
                        j = auxhdr.code & 255;
                        if ((hdr.code & 0x7f) == 0x7B)
                        {
                            if ((j == 0x22) || (j == 0x24) || (j == 0x2D) || (j == 0x2A) || (j == 0x29))
                            {
                                palhdr = auxhdr;
                                paloffs = auxoffs;
                            }
                        }
                    }
                    numscales = 0;

                    if (compressed == 0)
                    {
                        /* look for multiscale NFS5 bitmaps ? */
                        if ((hdr.misc[3] & 0x0fff) == 0) numscales = (hdr.misc[3] >> 12) & 0x0f;
                        if ((hdr.width % (1 << numscales)) != 0 || (hdr.height % (1 << numscales) != 0))
                        {
                            numscales = 0;
                        }

                        if (numscales != 0)
                        {
                            j = hdr.code & 0x7f;
                            if (j == 0x7B || j == 0x61) k = 2; /* in half-bytes per pixel ! */
                            else if (j == 0x7D) k = 8;
                            else if (j == 0x7F) k = 6;
                            else if (j == 0x60) k = 1;
                            else k = 4;
                            mbp_len = mbpp_len = 0;
                            for (l = 0; l <= numscales; l++)
                            {
                                bmpw = (hdr.width >> l);
                                if ((hdr.code & 0x7E) == 0x60) bmpw += (4 - bmpw) & 3; /* 4x4 DXT blocks */
                                m = (hdr.height >> l);
                                if ((hdr.code & 0x7E) == 0x60) m += (4 - m) & 3;
                                mbp_len += (bmpw * m) * k / 2;
                                mbpp_len += (bmpw * m) * k / 2;
                                if ((hdr.code & 0x7E) != 0x60)
                                {
                                    mbp_len += ((16 - mbp_len) & 15); /* padding */
                                    if (l == numscales) mbpp_len += ((16 - mbpp_len) & 15);
                                }
                            }
                            packed_mbp = 0;
                            if (((hdr.code >> 8) != mbp_len + 16) && ((hdr.code >> 8) != 0) ||
                                ((hdr.code >> 8) == 0) && (mbp_len + offs + 16 != nxoffs))
                            {
                                packed_mbp = 1;
                                if (((hdr.code >> 8) != mbpp_len + 16) && ((hdr.code >> 8) != 0) ||
                                    ((hdr.code >> 8) == 0) && (mbpp_len + offs + 16 != nxoffs))
                                {
                                    numscales = 0;
                                }
                            }
                        }
                    }
                }
                log.AppendFormat("{0} ", quotify(dir[i].name, 0, 4));

                if (isbmp)
                {
                    l = numscales;
                    curoffs = offs + 16;
                    bmpptr = inbuf;
                    j = nxoffs - curoffs;
                    if (compressed != 0)
                    {
                        bmpptr = uncompressData(inbuf, curoffs, ref j);
                        curoffs = 0;
                    }
                    sbuf = new FileReader(bmpptr);

                    if (numscales == 0)
                    {
                        log.AppendFormat("{0:D4}.BMP\n", i);
                        log.AppendFormat("BMP {0:X2} +{1} {2} {3} {{{4} {5} {6} {7}}}\n", hdr.code & 0xff, nattach, hdr.width, hdr.height, hdr.misc[0], hdr.misc[1], hdr.misc[2], hdr.misc[3]);
                    }
                    else
                    {
                        log.AppendFormat("{0:D4}-%d.BMP\n", i);
                        if (nattach != 0)
                            log.AppendFormat("MB{0}+{1} {2:X2} x{3} {4} {5} {{{6} {7} {8}}}\n", packed_mbp > 0 ? 'Q' : 'P', nattach,
                                hdr.code & 0xff, numscales, hdr.width, hdr.height,
                                hdr.misc[0], hdr.misc[1], hdr.misc[2]);
                        else
                            log.AppendFormat("MB{0} {1:X2} {2} {3} {4} {{{5} {6} {7}}}\n", packed_mbp > 0 ? 'Q' : 'P',
                                hdr.code & 0xff, numscales, hdr.width, hdr.height,
                                hdr.misc[0], hdr.misc[1], hdr.misc[2]);
                    }

                    while (l >= 0)
                    {
                        pad.Clear();
                        if (numscales != 0)
                        {
                            pad.AppendFormat("{0:D4}-{1}.BMP", i, l);
                        }
                        else
                        {
                            pad.AppendFormat("{0:D4}.BMP", i);
                        }
                        bmpfile = pad.ToString();
                        bmp = new List<byte>();
                        bmp.AddRange("BM".GetUTF8Bytes());
                        bmphdr = new BMPHEAD()
                        {
                            hsz = 40,
                            planes = 1,
                            wid = hdr.width,
                            hei = hdr.height
                        };

                        /* and also for the alpha channel if needed */
                        if (((hdr.code & 0x7f) == 0x7D) || ((hdr.code & 0x7f) == 0x7E) || ((hdr.code & 0x7f) == 0x6D) || ((hdr.code & 0x7f) == 0x61))
                        {
                            pad.Clear();
                            if (numscales != 0)
                            {
                                pad.AppendFormat("{0:D4}-{1}a.BMP", i, l);
                            }
                            else
                            {
                                pad.AppendFormat("{0:D4}-a.BMP", i);
                            }
                            if (l == numscales)
                            { /* only the first time */
                                if (numscales != 0)
                                {
                                    log.AppendFormat("alpha {0:D4}-%da.BMP\n", i);
                                }
                                else
                                {
                                    log.AppendFormat("alpha {0}\n", pad.ToString());
                                }

                            }

                            alphafile = pad.ToString();

                            alpha = new List<byte>();
                            alpha.AddRange("BM".GetUTF8Bytes());
                            /* alpha channel is always 8-bit */
                            bmpw = hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;
                            bmphdr.size = 54 + 4 * 256 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54 + 4 * 256;
                            bmphdr.bpp = 8;
                            bmphdr.imsz = bmpw * hdr.height;

                            alpha.AddRange(bmphdr.ToByteArray());
                        }

                        if ((hdr.code & 0x7f) == 0x7B)
                        {
                            /* 8-bit bitmap */
                            if (palhdr != null)
                            {
                                locpal = makepal(inbuf, paloffs, ref locpallen);

                                /* save some alpha channel data */
                                pad.Clear();
                                if (numscales != 0)
                                {
                                    pad.AppendFormat("{0:D4}-{1}.BMP", i, l);
                                }
                                else
                                {
                                    pad.AppendFormat("{0:D4}.BMP", i);
                                }
                                if (!makealpha8(out alpha8, pad.ToString(), locpal))
                                {
                                    if (l == numscales)
                                    {
                                        Debug.LogWarning("Couldn't write alpha channel data !");
                                    }
                                }
                            }
                            else if (hasglobpal >= 0)
                            {
                                System.Array.Copy(globpal, locpal, 256);
                                locpallen = globpallen;
                            }
                            else
                            {
                                locpal = new int[256];
                                locpallen = 0;
                            }

                            bmpw = hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;
                            bmphdr.size = 54 + 4 * 256 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54 + 4 * 256;
                            bmphdr.bpp = 8;
                            bmphdr.imsz = bmpw * hdr.height;
                            bmp.AddRange(bmphdr.ToByteArray());
                            bmp.AddRange(locpal.ToByteArray());
                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                for (n = 0; n < bmpw; n++)
                                {
                                    bmp.Add(bmpptr[(curoffs + k * hdr.width) + n]);
                                }
                            }
                            curoffs += hdr.width * hdr.height;
                        }
                        else if ((hdr.code & 0x7f) == 0x7D)
                        {
                            /* 32-bit bitmap */
                            for (k = 0; k < 256; k++)
                            {
                                locpal[k] = k * 0x01010101;
                            }
                            alpha.AddRange(locpal.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                ptr = new ArrayPtr<byte>(bmpptr, curoffs + 4 * k * hdr.width);
                                for (j = 0; j < hdr.width; j++)
                                {
                                    alpha.Add(ptr[4 * j + 3]);
                                }

                                // fill row up with padding bytes
                                for (j = hdr.width; j < bmpw; j++)
                                {
                                    alpha.Add(0);
                                }
                            }
                            alphas.Add(alphafile, alpha.ToArray());

                            bmpw = 3 * hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;

                            bmphdr.size = 54 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54;
                            bmphdr.bpp = 24;
                            bmphdr.imsz = bmpw * hdr.height;

                            bmp.AddRange(bmphdr.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                ptr = new ArrayPtr<byte>(bmpptr, curoffs + 4 * k * hdr.width);
                                for (j = 0; j < hdr.width; j++)
                                {
                                    bmp.Add(ptr[4 * j]);
                                    bmp.Add(ptr[4 * j + 1]);
                                    bmp.Add(ptr[4 * j + 2]);
                                }

                                // fill row up with padding bytes
                                for (j = 3 * hdr.width; j < bmpw; j++)
                                {
                                    bmp.Add(0);
                                }
                            }
                            curoffs += 4 * hdr.width * hdr.height;
                        }
                        else if ((hdr.code & 0x7f) == 0x7F)
                        {
                            /* 24-bit bitmap */
                            bmpw = 3 * hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;

                            bmphdr.size = 54 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54;
                            bmphdr.bpp = 24;
                            bmphdr.imsz = bmpw * hdr.height;

                            bmp.AddRange(bmphdr.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                tmp = new byte[bmpw];
                                System.Array.Copy(bmpptr, curoffs + 3 * k * hdr.width, tmp, 0, bmpw);
                                bmp.AddRange(tmp);
                            }
                            curoffs += 3 * hdr.width * hdr.height;
                        }
                        else if ((hdr.code & 0x7f) == 0x7E)
                        {
                            /* 15-bit bitmap */
                            for (k = 0; k < 256; k++) locpal[k] = 0;
                            locpal[0] = unchecked((int)0xffffffff);
                            alpha.AddRange(locpal.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                sbuf.setCurrPos(curoffs + 2 * k * hdr.width);
                                for (j = 0; j < hdr.width; j++)
                                {
                                    value = (sbuf.readUShort() & 0x8000) > 0 ? (byte)0 : (byte)1;
                                    alpha.Add(value);
                                }

                                // fill row up with padding bytes
                                for (j = hdr.width; j < bmpw; j++)
                                {
                                    alpha.Add(0);
                                }
                            }
                            alphas.Add(alphafile, alpha.ToArray());

                            bmpw = 3 * hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;
                            bmphdr.size = 54 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54;
                            bmphdr.bpp = 24;
                            bmphdr.imsz = bmpw * hdr.height;

                            bmp.AddRange(bmphdr.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                sbuf.setCurrPos(curoffs + 2 * k * hdr.width);
                                for (j = 0; j < hdr.width; j++)
                                {
                                    us1 = sbuf.readUShort();
                                    bmp.Add((byte)((us1 & 0x1f) << 3));
                                    bmp.Add((byte)(((us1 >> 5) & 0x1f) << 3));
                                    bmp.Add((byte)(((us1 >> 10) & 0x1f) << 3));
                                }

                                // fill row up with padding bytes
                                for (j = 3 * hdr.width; j < bmpw; j++)
                                {
                                    bmp.Add(0);
                                }
                            }
                            curoffs += 2 * hdr.width * hdr.height;
                        }
                        else if ((hdr.code & 0x7f) == 0x78)
                        {
                            /* 15-bit bitmap */
                            bmpw = 3 * hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;
                            bmphdr.size = 54 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54;
                            bmphdr.bpp = 24;
                            bmphdr.imsz = bmpw * hdr.height;

                            bmp.AddRange(bmphdr.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                sbuf.setCurrPos(curoffs + 2 * k * hdr.width);
                                for (j = 0; j < hdr.width; j++)
                                {
                                    us1 = sbuf.readUShort();
                                    bmp.Add((byte)((us1 & 0x1f) << 3));
                                    bmp.Add((byte)(((us1 >> 5) & 0x3f) << 2));
                                    bmp.Add((byte)(((us1 >> 11) & 0x1f) << 3));
                                }

                                // fill row up with padding bytes
                                for (j = 3 * hdr.width; j < bmpw; j++)
                                {
                                    bmp.Add(0);
                                }
                            }
                            curoffs += 2 * hdr.width * hdr.height;
                        }
                        else if ((hdr.code & 0x7f) == 0x6D)
                        {
                            /* 4x4=16-bit bitmap */
                            for (k = 0; k < 16; k++) locpal[k] = k * 0x11111111;
                            for (k = 16; k < 256; k++) locpal[k] = 0;
                            alpha.AddRange(locpal.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                ptr = new ArrayPtr<byte>(bmpptr, curoffs + 2 * k * hdr.width);
                                for (j = 0; j < hdr.width; j++)
                                {
                                    alpha.Add((byte)(ptr[2 * j + 1] >> 4));
                                }

                                // fill row up with padding bytes
                                for (j = hdr.width; j < bmpw; j++)
                                {
                                    alpha.Add(0);
                                }
                            }
                            alphas.Add(alphafile, alpha.ToArray());

                            bmpw = 3 * hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;
                            bmphdr.size = 54 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54;
                            bmphdr.bpp = 24;
                            bmphdr.imsz = bmpw * hdr.height;
                            bmp.AddRange(bmphdr.ToByteArray());

                            for (k = hdr.height - 1; k >= 0; k--)
                            {
                                ptr = new ArrayPtr<byte>(bmpptr, curoffs + 2 * k * hdr.width);
                                for (j = 0; j < hdr.width; j++)
                                {
                                    bmp.Add((byte)(0x11 * (ptr[2 * j] & 15)));
                                    bmp.Add((byte)(0x11 * (ptr[2 * j] >> 4)));
                                    bmp.Add((byte)(0x11 * (ptr[2 * j + 1] & 15)));
                                }

                                // fill row up with padding bytes
                                for (j = 3 * hdr.width; j < bmpw; j++)
                                {
                                    bmp.Add(0);
                                }
                            }
                            curoffs += 2 * hdr.width * hdr.height;
                        }
                        else if ((hdr.code & 0x7f) == 0x61)
                        {
                            /* NFS6 DXT3 packed bitmap */
                            for (k = 0; k < 16; k++) locpal[k] = k * 0x11111111;
                            for (k = 16; k < 256; k++) locpal[k] = 0;
                            alpha.AddRange(locpal.ToByteArray());
                            for (k = hdr.height / 4 - 1; k >= 0; k--)
                            {
                                ptr = new ArrayPtr<byte>(bmpptr, curoffs + 4 * k * hdr.width);
                                for (m = 6; m >= 0; m -= 2)
                                {
                                    for (j = 0; j < hdr.width / 4; j++)
                                    {
                                        alpha.Add((byte)(ptr[16 * j + m] & 15));
                                        alpha.Add((byte)(ptr[16 * j + m] >> 4));
                                        alpha.Add((byte)(ptr[16 * j + m + 1] & 15));
                                        alpha.Add((byte)(ptr[16 * j + m + 1] >> 4));
                                    }
                                }
                            }
                            alphas.Add(alphafile, alpha.ToArray());

                            bmpw = 3 * hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;
                            bmphdr.size = 54 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54;
                            bmphdr.bpp = 24;
                            bmphdr.imsz = bmpw * hdr.height;
                            bmp.AddRange(bmphdr.ToByteArray());

                            for (k = hdr.height / 4 - 1; k >= 0; k--)
                            {
                                ptr = new ArrayPtr<byte>(bmpptr, curoffs + 4 * k * hdr.width);
                                for (m = 15; m >= 12; m--)
                                {
                                    for (j = 0; j < hdr.width / 4; j++)
                                    {
                                        sbuf.setCurrPos((curoffs + 4 * k * hdr.width) + 8 * j + 4);
                                        us1 = sbuf.readUShort();
                                        us2 = sbuf.readUShort();
                                        bmp.AddRange(unpackDXT((byte)(ptr[16 * j + m] & 3), us1, us2));
                                        bmp.AddRange(unpackDXT((byte)((ptr[16 * j + m] >> 2) & 3), us1, us2));
                                        bmp.AddRange(unpackDXT((byte)((ptr[16 * j + m] >> 4) & 3), us1, us2));
                                        bmp.AddRange(unpackDXT((byte)((ptr[16 * j + m] >> 6) & 3), us1, us2));
                                    }

                                    // fill row up with padding bytes
                                    for (j = hdr.width; j < bmpw; j++)
                                    {
                                        bmp.Add(0);
                                    }
                                }
                            }
                            curoffs += hdr.width * hdr.height;
                        }
                        else if ((hdr.code & 0x7f) == 0x60)
                        {
                            /* NFS6 DXT1 packed bitmap */
                            bmpw = 3 * hdr.width;
                            while ((bmpw & 3) > 0) bmpw++;
                            bmphdr.size = 54 + bmpw * hdr.height;
                            bmphdr.ofsbmp = 54;
                            bmphdr.bpp = 24;
                            bmphdr.imsz = bmpw * hdr.height;
                            bmp.AddRange(bmphdr.ToByteArray());

                            for (k = hdr.height / 4 - 1; k >= 0; k--)
                            {
                                ptr = new ArrayPtr<byte>(bmpptr, curoffs + 2 * k * hdr.width);
                                for (m = 7; m >= 4; m--)
                                {
                                    for (j = 0; j < hdr.width / 4; j++)
                                    {
                                        sbuf.setCurrPos((curoffs + 2 * k * hdr.width) + 4 * j);
                                        us1 = sbuf.readUShort();
                                        us2 = sbuf.readUShort();
                                        bmp.AddRange(unpackDXT((byte)(ptr[8 * j + m] & 3), us1, us2));
                                        bmp.AddRange(unpackDXT((byte)((ptr[8 * j + m] >> 2) & 3), us1, us2));
                                        bmp.AddRange(unpackDXT((byte)((ptr[8 * j + m] >> 4) & 3), us1, us2));
                                        bmp.AddRange(unpackDXT((byte)((ptr[8 * j + m] >> 6) & 3), us1, us2));
                                    }

                                    // fill row up with padding bytes
                                    for (j = hdr.width; j < bmpw; j++)
                                    {
                                        bmp.Add(0);
                                    }
                                }
                            }
                            curoffs += hdr.width * hdr.height / 2;
                        }
                        bmps.Add(bmpfile, bmp.ToArray());

                        if (numscales != 0)
                        { /* multiscale loop */
                            hdr.width /= 2;
                            hdr.height /= 2;
                            if ((hdr.code & 0x7E) == 0x60)
                            {
                                hdr.width += (short)((4 - hdr.width) & 3);  /* 4x4 blocks */
                                hdr.height += (short)((4 - hdr.height) & 3);
                            }
                            else
                            {
                                j = (curoffs - offs) & 15;
                                if (j != 0 && (packed_mbp == 0)) curoffs += 16 - j; /* padding */
                            }
                        }
                        l--;
                    }
                    if (compressed != 0)
                    {
                        if ((hdr.code >> 8) != 0) curoffs = offs + (hdr.code >> 8);
                        else curoffs = nxoffs;
                    }

                    /* now, look at the attachments if any */
                    auxhdr = hdr; auxoffs = offs;
                    k = nattach;
                    while (k > 0)
                    {
                        k--;
                        auxoffs += (auxhdr.code >> 8);
                        if (curoffs < auxoffs)
                        {
                            log.AppendFormat("!PAD {0} ", auxoffs - curoffs);
                            log.AppendLine(hexify(inbuf, curoffs, auxoffs - curoffs).GetUTF8String());
                        }
                        auxhdr = new ENTRYHDR(inbuf, auxoffs);
                        j = auxhdr.code & 0xff;
                        if (((hdr.code & 0x7f) == 0x7b) && (auxhdr.Equals(palhdr)))
                        {
                            log.AppendFormat("PAL {0:X2} {1} {2} {{{3} {4} {5} {6}}}\n", auxhdr.code & 0xff, auxhdr.width, auxhdr.height, auxhdr.misc[0], auxhdr.misc[1], auxhdr.misc[2], auxhdr.misc[3]);
                            if ((j == 0x2D) || (j == 0x29)) j = 2;
                            else if (j == 0x2A) j = 4;
                            else j = 3;
                            curoffs = auxoffs + 16 + auxhdr.width * j;
                        }
                        else if ((auxhdr.code & 0xff) == 0x6F)
                        {
                            log.AppendFormat("TXT {0:X2} {1} {2}\n", auxhdr.code & 0xff, auxhdr.width, auxhdr.height);
                            log.AppendLine(quotify(inbuf, auxoffs + 8, auxhdr.width));
                            curoffs = auxoffs + 8 + auxhdr.width;
                        }
                        else if ((auxhdr.code & 0xff) == 0x69)
                        {
                            log.AppendFormat("ETXT {0:X2} {1} {2} {{{3} {4} {5} {6}}}\n",
                               auxhdr.code & 0xff, auxhdr.width, auxhdr.height,
                               auxhdr.misc[0], auxhdr.misc[1], auxhdr.misc[2], auxhdr.misc[3]);
                            log.AppendLine(quotify(inbuf, auxoffs + 16, auxhdr.width));
                            curoffs = auxoffs + 16 + auxhdr.width;
                        }
                        else if ((auxhdr.code & 0xff) == 0x70)
                        {
                            log.AppendFormat("ETXT {0:X2} ", auxhdr.code & 0xff);
                            log.AppendLine(quotify(inbuf, auxoffs + 4, 12));
                            curoffs = auxoffs + 16;
                        }
                        else
                        {
                            j = auxhdr.code >> 8;
                            if (j == 0) j = nxoffs - auxoffs;
                            if (j > 16384) { Debug.LogError("Attached data too large !"); }
                            log.AppendFormat("BIN {0:X2} {1}\n", auxhdr.code & 0xff, j);
                            log.AppendLine(hexify(inbuf, auxoffs, j).GetUTF8String());
                            curoffs = auxoffs + j;
                        }
                    }

                    if (curoffs < nxoffs)
                    {
                        log.AppendFormat("!PAD {0} ", nxoffs - curoffs);
                        log.AppendLine(hexify(inbuf, curoffs, nxoffs - curoffs).GetUTF8String());
                    }
                    if (curoffs > nxoffs)
                    {
                        Debug.LogWarning("WARNING: passed the next block ?");
                    }
                }
                else
                {
                    /* not a bitmap */
                    j = hdr.code & 0xff;
                    log.AppendFormat("{0:D4}.BIN\nBIN\n", i);
                    bmp = new List<byte>();
                    /* v1.11 bugfix */
                    for (i = offs; i < nxoffs - offs; i++)
                    {
                        bmp.Add(inbuf[i]);
                    }
                    bmps.Add(bmpfile, bmp.ToArray());
                }
            }

            log.AppendLine("#END");
            fshindex = log.ToString();
        }

        private byte[] unpackDXT(byte mask, ushort col1, ushort col2)
        {
            byte[] result = new byte[3];
            byte r1, g1, b1, r2, g2, b2;
            r1 = (byte)(8 * (col1 & 31)); g1 = (byte)(4 * ((col1 >> 5) & 63)); b1 = (byte)(8 * (col1 >> 11));
            r2 = (byte)(8 * (col2 & 31)); g2 = (byte)(4 * ((col2 >> 5) & 63)); b2 = (byte)(8 * (col2 >> 11));

            switch (mask)
            {
                case 0: result[0] = r1; result[1] = g1; result[2] = b1; break;
                case 1: result[0] = r2; result[1] = g2; result[2] = b2; break;
                case 2:
                    if (col1 > col2)
                    {
                        result[0] = (byte)((2 * r1 + r2) / 3); result[1] = (byte)((2 * g1 + g2) / 3); result[2] = (byte)((2 * b1 + b2) / 3);
                    }
                    else
                    {
                        result[0] = (byte)((r1 + r2) / 2); result[1] = (byte)((g1 + g2) / 2); result[2] = (byte)((b1 + b2) / 2);
                    }
                    break;
                case 3:
                    if (col1 > col2)
                    {
                        result[0] = (byte)((r1 + 2 * r2) / 3); result[1] = (byte)((g1 + 2 * g2) / 3); result[2] = (byte)((b1 + 2 * b2) / 3);
                    }
                    else
                    {
                        result[0] = result[1] = result[2] = 0;
                    }
                    break;
            }
            return result;
        }

        private string quotify(byte[] src, int offset, int len)
        {
            StringBuilder result = new StringBuilder();
            for (int i = offset; i < offset + len; i++)
            {
                if ((src[i] > 32) && (src[i] <= 126) && (src[i] != '%'))
                {
                    result.Append((char)src[i]);
                }
                else
                {
                    result.Append('%');
                    result.Append(HEXDIGITS[src[i] >> 4]);
                    result.Append(HEXDIGITS[src[i] & 15]);
                }
            }
            return result.ToString();
        }

        private byte[] hexify(byte[] src, int offset, int len)
        {
            List<byte> result = new List<byte>();
            for (int i = offset; i < offset + len; i++)
            {
                result.Add((byte)HEXDIGITS[src[i] >> 4]);
                result.Add((byte)HEXDIGITS[src[i] & 15]);
            }
            return result.ToArray();
        }

        private bool makealpha8(out byte[] alpha8, string fname, int[] pal)
        {
            List<byte> result = new List<byte>();

            byte[] alpha = new byte[256];
            byte[] hex;

            for (int i = 0; i < 256; i++)
            {
                alpha[i] = (byte)(pal[i] >> 24);
                //Debug.Log(Convert.ToString(pal[i], 2).PadLeft(32, '0'));
            }
            hex = hexify(alpha, 0, alpha.Length);
            result.AddRange((fname + "\n").GetUTF8Bytes());
            result.AddRange(hex);
            result.AddRange("\n".GetUTF8Bytes());

            for (int i = 0; i < hex.Length; i++)
            {
                //Debug.LogFormat("{0}", hex[i]);
            }

            alpha8 = result.ToArray();

            return true;
        }
        private int[] makepal(byte[] buf, int pos, ref int len)
        {
            int[] pal;
            int code;
            ENTRYHDR hdr;

            FileReader fr = new FileReader(buf);
            fr.setCurrPos(pos + 16);

            pal = new int[256];

            hdr = new ENTRYHDR(buf, pos);
            code = hdr.code & 0xff;
            len = hdr.width;

            if (code == 0x24)
            {
                for (int i = 0; i < len; i++)
                    pal[i] = 65536 * fr.readByte() + 256 * fr.readByte() + fr.readByte();
            }
            else if (code == 0x22)
            {
                for (int i = 0; i < len; i++)
                    pal[i] = (65536 * fr.readByte() + 256 * fr.readByte() + fr.readByte()) << 2;
            }
            else if (code == 0x2D)
            {
                for (int i = 0; i < len; i++)
                {
                    ushort s = fr.readUShort();
                    pal[i] = ((s & 0x1F) + 256 * ((s >> 5) & 0x1F) + 65536 * ((s >> 10) & 0x1F)) << 3;
                    if ((s & 0x8000) != 0) pal[i] += unchecked((int)0xFF000000);
                }
            }
            else if (code == 0x29)
            {
                for (int i = 0; i < len; i++)
                {
                    ushort s = fr.readUShort();
                    pal[i] = ((s & 0x1f) + 128 * ((s >> 5) & 0x3F) + 65536 * ((s >> 11) & 0x1F)) << 3;
                }
            }
            else if (code == 0x2A)
            {
                for (int i = 0; i < len; i++)
                {
                    pal[i] = fr.readInt();
                }
            }
            else { Debug.LogError("Unknown palette format."); }

            //for (int x = 0; x < 256; x++)
            //{
            //    Debug.Log(pal[x]);
            //}

            return pal;
        }

        private byte[] uncompressData(byte[] inbuf, int bufOffset, ref int buflen)
        {
            byte[] outbuf;
            byte packcode;
            int a, b, c, len, offset;
            int inlen, outlen, inpos, outpos;

            /* length of data */
            inlen = buflen;
            outlen = (inbuf[bufOffset + 2] << 16) + (inbuf[bufOffset + 3] << 8) + inbuf[bufOffset + 4];
            outbuf = new byte[outlen];

            if (outbuf == null)
            {
                Debug.LogError("Insufficient memory.\n");
                return null;
            }

            /* position in file */
            if ((inbuf[bufOffset + 0] & 0x01) != 0)
            {
                inpos = 8;
            }
            else
            {
                inpos = 5;
            }

            outpos = 0;

            /* main decoding loop */
            while ((inpos < inlen) && (inbuf[bufOffset + inpos] < 0xFC))
            {

                packcode = inbuf[bufOffset + inpos];
                a = inbuf[bufOffset + inpos + 1];
                b = inbuf[bufOffset + inpos + 2];

                if ((packcode & 0x80) == 0)
                {
                    len = packcode & 3;
                    mmemcpy(outbuf, inbuf, outpos, bufOffset + inpos + 2, len);
                    inpos += len + 2;
                    outpos += len;
                    len = ((packcode & 0x1c) >> 2) + 3;
                    offset = ((packcode >> 5) << 8) + a + 1;
                    mmemcpy(outbuf, outbuf, outpos, outpos - offset, len);
                    outpos += len;
                }
                else if ((packcode & 0x40) == 0)
                {
                    len = (a >> 6) & 3;
                    mmemcpy(outbuf, inbuf, outpos, bufOffset + inpos + 3, len);
                    inpos += len + 3;
                    outpos += len;
                    len = (packcode & 0x3f) + 4;
                    offset = (a & 0x3f) * 256 + b + 1;
                    mmemcpy(outbuf, outbuf, outpos, outpos - offset, len);
                    outpos += len;
                }
                else if ((packcode & 0x20) == 0)
                {
                    c = inbuf[bufOffset + inpos + 3];
                    len = packcode & 3;
                    mmemcpy(outbuf, inbuf, outpos, bufOffset + inpos + 4, len);
                    inpos += len + 4;
                    outpos += len;
                    len = ((packcode >> 2) & 3) * 256 + c + 5;
                    offset = ((packcode & 0x10) << 12) + 256 * a + b + 1;
                    mmemcpy(outbuf, outbuf, outpos, outpos - offset, len);
                    outpos += len;
                }
                else
                {
                    len = (packcode & 0x1f) * 4 + 4;
                    mmemcpy(outbuf, inbuf, outpos, bufOffset + inpos + 1, len);
                    inpos += len + 1;
                    outpos += len;
                }
            }

            /* trailing bytes */
            if ((inpos < inlen) && (outpos < outlen))
            {
                mmemcpy(outbuf, inbuf, outpos, bufOffset + inpos + 1, inbuf[bufOffset + inpos] & 3);
                outpos += inbuf[bufOffset + inpos] & 3;
            }

            if (outpos != outlen)
            {
                Debug.LogWarningFormat("Warning: bad length ? {0} instead of {1}\n", outpos, outlen);
            }

            buflen = outlen;

            return outbuf;
        }

        private void mmemcpy<T>(T[] outbuf, T[] inbuf, int outIndex, int inIndex, int len)
        {
            if (outbuf == null || inbuf == null)
            {
                throw new NullReferenceException();
            }
            else if (outbuf.Length < outIndex + len || inbuf.Length < inIndex + len)
            {
                throw new Exception("input or output buffer is too short");
            }
            for (int i = 0; i < len; i++)
            {
                outbuf[outIndex + i] = inbuf[inIndex + i];
            }
        }

        private class FSHHDR
        {
            /* header of a FSH file */
            public byte[] SHPI = new byte[4]; /* = char SHPI[4] 'SHPI' */
            public int filesize;
            public int nbmp;
            public byte[] dirId; /* char dirId[4]; */

            public FSHHDR(byte[] buf, int pos)
            {
                setData(buf, pos);
            }

            public void setData(byte[] buf, int pos)
            {
                FileReader fr = new FileReader(buf);
                fr.setCurrPos(pos);
                for (int i = 0; i < 4; i++)
                {
                    this.SHPI[i] = fr.readByte();
                }
                this.filesize = fr.readInt();
                this.nbmp = fr.readInt();
                this.dirId = fr.readBytes(4);
            }

        }

        private class BMPDIR : Arrayable<BMPDIR>
        {
            // size in byte
            private const int NBYTES = 8;
            public byte[] name; /* = char name[4]; */
            public int ofs;

            public int getNBytes()
            {
                return NBYTES;
            }

            public void setData(byte[] buf, int pos)
            {
                FileReader fr = new FileReader(buf);
                fr.setCurrPos(pos);
                this.name = fr.readBytes(4);
                this.ofs = fr.readInt();
            }
        }

        private class ENTRYHDR
        {
            private int pos;
            private byte[] buf;
            public int code;
            public short width, height;
            public short[] misc = new short[4]; /* = short misc[4]; */

            public ENTRYHDR(byte[] buf, int pos)
            {
                setData(buf, pos);
            }

            public void setData(byte[] buf, int pos)
            {
                FileReader fr = new FileReader(buf);
                fr.setCurrPos(pos);
                this.code = fr.readInt();
                this.width = fr.readShort();
                this.height = fr.readShort();
                for (int i = 0; i < 4; i++)
                {
                    this.misc[i] = fr.readShort();
                }

                this.pos = pos;
                this.buf = buf;
            }

            public override bool Equals(object obj)
            {
                //Check for null and compare run-time types.
                if ((obj == null) || !this.GetType().Equals(obj.GetType()))
                {
                    return false;
                }
                else
                {
                    ENTRYHDR p = (ENTRYHDR)obj;
                    return (pos == p.pos) && (buf == p.buf);
                }
            }

            public override int GetHashCode()
            {
                return (pos << 2) ^ buf.GetHashCode();
            }
        }

        private class BMPHEAD
        {
            public int size = 0, nul = 0, ofsbmp = 0;
            public int hsz = 0, wid = 0, hei = 0;
            public short planes = 0, bpp = 0;
            public int compr = 0, imsz = 0, xpel = 0, ypel = 0, clrs = 0, clri = 0;

            public byte[] ToByteArray()
            {
                List<byte> result = new List<byte>();
                result.AddRange(BitConverter.GetBytes(size));
                result.AddRange(BitConverter.GetBytes(nul));
                result.AddRange(BitConverter.GetBytes(ofsbmp));
                result.AddRange(BitConverter.GetBytes(hsz));
                result.AddRange(BitConverter.GetBytes(wid));
                result.AddRange(BitConverter.GetBytes(hei));
                result.AddRange(BitConverter.GetBytes(planes));
                result.AddRange(BitConverter.GetBytes(bpp));
                result.AddRange(BitConverter.GetBytes(compr));
                result.AddRange(BitConverter.GetBytes(imsz));
                result.AddRange(BitConverter.GetBytes(xpel));
                result.AddRange(BitConverter.GetBytes(ypel));
                result.AddRange(BitConverter.GetBytes(clrs));
                result.AddRange(BitConverter.GetBytes(clri));
                return result.ToArray();
            }
        }

        private class StructArray<T> where T : Arrayable<T>, new()
        {

            private byte[] buf;
            private int startIndex;

            public StructArray(byte[] buf, int startIndex)
            {
                this.buf = buf;
                this.startIndex = startIndex;
            }

            public T this[int index]
            {
                get
                {
                    T instance = new T();
                    instance.setData(buf, startIndex + instance.getNBytes() * index);
                    return instance;
                }
            }
        }

        private interface Arrayable<T>
        {
            int getNBytes();
            void setData(byte[] buf, int pos);
        }

        private class ArrayPtr<T>
        {
            private T[] array;
            private int offset;

            public ArrayPtr(T[] array, int offset)
            {
                this.array = array;
                this.offset = offset;
            }

            public T this[int index]
            {
                get
                {
                    return array[index + offset];
                }
            }
        }
    }
}
