using System;
using System.Collections.Generic;

using NFS3Importer.HullDelaunayVoronoi.Hull;
using NFS3Importer.HullDelaunayVoronoi.Primitives;

namespace NFS3Importer.HullDelaunayVoronoi.Delaunay
{
	
	public interface IDelaunayTriangulation<VERTEX>
        where VERTEX : class, IVertex, new()
	{

        int Dimension { get; }
		
		IList<VERTEX> Vertices { get; }

		IList<DelaunayCell<VERTEX>> Cells { get; }

        VERTEX Centroid { get; }

		void Clear();

        void Generate(IList<VERTEX> input, bool assignIds = true, bool checkInput = false);
		
	}
	
}












