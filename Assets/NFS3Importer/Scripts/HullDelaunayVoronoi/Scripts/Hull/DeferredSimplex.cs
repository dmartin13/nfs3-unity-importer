using System;
using System.Collections.Generic;

using NFS3Importer.HullDelaunayVoronoi.Primitives;

namespace NFS3Importer.HullDelaunayVoronoi.Hull
{
    /// <summary>
    /// For deferred face addition.
    /// </summary>
    internal class DeferredSimplex<VERTEX>
        where VERTEX : IVertex, new()
    {
        /// <summary>
        /// The faces.
        /// </summary>
        internal SimplexWrap<VERTEX> Face { get; set; }

        internal SimplexWrap<VERTEX> Pivot { get; set; }

        internal SimplexWrap<VERTEX> OldFace { get; set; }

        /// <summary>
        /// The indices.
        /// </summary>
        internal int FaceIndex { get; set; }

        internal int PivotIndex { get; set; }
    }

}