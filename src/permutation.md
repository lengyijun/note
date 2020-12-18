# 排列数与组合数
在做算法题的时候经常需要用到排列数和组合数。
于是我首先写了一个命令行的计算组合数和排列数的工具。
他接受两个参数，分别是n和r.顺序无所谓，反正我会自动调整顺序的。

然后我们需要所有的组合，比如 [1,2,3], 给出所有的排列，就是

[1,2,3]
[1,3,2]
[2,1,3]
[2,3,1]
[3,1,2]
[3,2,1]

计算这个，我们一般是用dfs做的。不过我发现了cpp中next_permutation这个函数之后，发觉了更好玩的算法

1. 从后往前寻找索引满足 a[k] < a[k + 1], 如果此条件不满足，则说明已遍历到最后一个。
2. 从后往前遍历，找到第一个比a[k]大的数a[l], 即a[k] < a[l].
3. 交换a[k]与a[l].
4. 反转k + 1 ~ n之间的元素。

用cpp写是这样

```
class Solution {
public:
    /**
     * @param nums: An array of integers
     * @return: An array of integers that's next permuation
     */
    vector<int> nextPermutation(vector<int> &nums) {
        if (nums.empty() || nums.size() <= 1) {
            return nums;
        }
        // step1: find nums[i] < nums[i + 1]
        int i = 0;
        for (i = nums.size() - 2; i >= 0; --i) {
            if (nums[i] < nums[i + 1]) {
                break;
            } else if (0 == i) {
                // reverse nums if reach maximum
                reverse(nums, 0, nums.size() - 1);
                return nums;
            }
        }
        // step2: find nums[i] < nums[j]
        int j = 0;
        for (j = nums.size() - 1; j > i; --j) {
            if (nums[i] < nums[j]) break;
        }
        // step3: swap betwenn nums[i] and nums[j]
        int temp = nums[i];
        nums[i] = nums[j];
        nums[j] = temp;
        // step4: reverse between [i + 1, n - 1]
        reverse(nums, i + 1, nums.size() - 1);

        return nums;

    }

private:
    void reverse(vector<int>& nums, int start, int end) {
        for (int i = start, j = end; i < j; ++i, --j) {
            int temp = nums[i];
            nums[i] = nums[j];
            nums[j] = temp;
        }
    }
};
```

用rust写大概是这样
```
fn next_permutation<A:PartialOrd>(mut x: Vec<A>) -> Option<Vec<A>> {
    let mut a = x.len();

    let mut i = a - 2;
    loop {
        if x[i + 1] > x[i] {
            break;
        }
        if i==0 {
            //the last one
            return None;
        }
        i -= 1;
    }

    let mut j = a - 1;
    while j > i {
        if x[i] < x[j] {
            break;
        }
        j -= 1;
    }

    x.swap(i, j);

    i += 1;
    a -= 1;
    while i < a {
        x.swap(i, a);
        i += 1;
        a -= 1;
    }
    Some(x)
}
```

所以需要数组中的元素是可比较的
