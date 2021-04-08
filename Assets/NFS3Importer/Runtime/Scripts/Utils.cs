namespace NFS3Importer.Runtime {
    public static class Utils {
        /// <summary>
        /// calculates the modulo of x divided by n
        /// </summary>
        /// <param name="x"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public static int ModN(int x,int n){
            return (x % n + n) % n;
        }

        /// <summary>
        /// checks if a value is inside a range of a circular (modulo) interval 
        /// </summary>
        /// <param name="x"></param>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public static bool PointInClosedInterval(int x, int a, int b, int n) {
            // https://fgiesen.wordpress.com/2015/09/24/intervals-in-modular-arithmetic/
            return ModN(ModN(x, n) - a, n) <= ModN(b - a, n);
        }

        public static (int, int) RemapCircularInterval((int, int) interval, int offset ,int n) {
            return (ModN(interval.Item1 + offset, n), ModN(interval.Item2 + offset, n));
        }
    }
}
