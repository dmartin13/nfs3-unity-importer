using System;
using System.Collections.Generic;

using NFS3Importer.HullDelaunayVoronoi.Primitives;
using NFS3Importer.HullDelaunayVoronoi.Delaunay;

namespace NFS3Importer.HullDelaunayVoronoi.Voronoi
{
	
	public interface IVoronoiMesh<VERTEX>
        where VERTEX : class, IVertex, new()
    {

		int Dimension { get; }

        IList<DelaunayCell<VERTEX>> Cells { get; }

        IList<VoronoiRegion<VERTEX>> Regions { get; }

        void Clear();
		
		void Generate(IList<VERTEX> input, bool assignIds = true, bool checkInput = false);
		
	}
	
}












