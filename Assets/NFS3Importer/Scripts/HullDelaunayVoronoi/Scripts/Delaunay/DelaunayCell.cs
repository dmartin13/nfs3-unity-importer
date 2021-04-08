﻿using System;
using System.Collections;

using NFS3Importer.HullDelaunayVoronoi.Primitives;

namespace NFS3Importer.HullDelaunayVoronoi.Delaunay
{
	public class DelaunayCell<VERTEX>
        where VERTEX : class, IVertex, new()
	{

        public Simplex<VERTEX> Simplex { get; private set; }
		
		public VERTEX CircumCenter { get; private set; }
		
		public float Radius { get; private set; }

        public DelaunayCell(Simplex<VERTEX> simplex, float[] circumCenter, float radius)
		{
            Simplex = simplex;

			CircumCenter = new VERTEX();
			CircumCenter.Position = circumCenter;

			Radius = radius;
		}
		
	}
	
}
