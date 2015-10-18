using System;
using System.Collections.Generic;

class Solution {
    
    public int getLeftIndex(ref int[] A)
    {
        for(int i = 0; i < A.Length; ++i)
        {
            if(A[i] == 0)
            {
                return i;
            }
        }
        return -1;
    }
    
    public int getRightIndex(ref int[] A)
    {
        for(int i = A.Length - 1; i >= 0; --i)
        {
            if(A[i] == 1)
            {
                return i;
            }
        }
        return -1;
    }
    
    public int solution(int[] A) 
    {
        List<int> zeroLeft = new List<int>();
        List<int> onesLeft = new List<int>();
        List<int> zeroRight = new List<int>();
        List<int> onesRight = new List<int>();
        
        int startLeftIndex = this.getLeftIndex(ref A);
        int startRightIndex = this.getRightIndex(ref A);
        
        if(startLeftIndex == -1 || 
           startRightIndex == -1 || 
           startLeftIndex >= startRightIndex)
        {
            return 0;
        }
        
        int zeroCount = 0;
        int onesCount = 0;
        
        for(int i = startLeftIndex; i <= startRightIndex; ++i)
        {
            if(A[i] == 0)
            {
                ++zeroCount;
            }
            else
            {
                ++onesCount;
            }
            
            zeroLeft.Add(zeroCount);
            onesLeft.Add(onesCount);   
        }
        
        zeroCount = 0;
        onesCount = 0;
        
        for(int i = startRightIndex; i >= startLeftIndex; --i)
        {
            if(A[i] == 0)
            {
                ++zeroCount;
            }
            else
            {
                ++onesCount;
            }
            
            zeroRight.Add(zeroCount);
            onesRight.Add(onesCount);
        }
        
        int rezult = 0;
        int length = zeroLeft.Count;
        
        zeroCount = startLeftIndex;
        onesCount = A.Length - startRightIndex - 1;
        
        for(int i = 0; i < zeroLeft.Count - 1; ++i)
        {
            if(zeroLeft[i] > onesLeft[i] && onesRight[length - 1 - i] > zeroRight[length - 1 - i])
            {
                int tempRezult = Math.Min(zeroLeft[i] - onesLeft[i] - 1, zeroCount) +
                    Math.Min(onesRight[length - 1 - i] - zeroRight[length - 1 - i] - 1, onesCount) +
                    startRightIndex - startLeftIndex + 1;
                
                rezult = Math.Max(rezult, tempRezult);
            }
        }
        
        return rezult;
    }
}