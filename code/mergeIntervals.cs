
Problem
Given an array of intervals where intervals[i] = [start, end], merge all overlapping intervals.
Example
Input:
[[1,3],[2,6],[8,10],[15,18]]
Output:
[[1,6],[8,10],[15,18]]


Approach
Sort intervals by start time.
Add the first interval to the result.
Iterate through remaining intervals:
If current interval overlaps with the last merged interval:
Update the end as max(last.end, current.end).
Otherwise:
Add the current interval to the result.
Time Complexity
Sorting: O(n log n)
Traversal: O(n)
Overall: O(n log n)
Space Complexity
O(n) (result list)




public class Solution
{
    public int[][] Merge(int[][] intervals)
    {
        if (intervals.Length <= 1)
            return intervals;

        Array.Sort(intervals, (a, b) => a[0].CompareTo(b[0]));

        List<int[]> result = new List<int[]>();

        result.Add(intervals[0]);

        foreach (var interval in intervals.Skip(1))
        {
            int[] last = result[result.Count - 1];

            if (interval[0] <= last[1]) // Overlap
            {
                last[1] = Math.Max(last[1], interval[1]);
            }
            else
            {
                result.Add(interval);
            }
        }

        return result.ToArray();
    }
}