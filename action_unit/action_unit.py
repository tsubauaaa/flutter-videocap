import re

import matplotlib.pyplot as plt
import pandas as pd

df = pd.read_csv("./csv/face-nakamura.csv")

# ActionUnitsのカラム名のリストを作成する
target_columns = [x for x in df.columns if re.match(r"^AU.+_r$", x)]
print(f"target_columns: {target_columns}")

# 特徴のあるAUをとってくる (分散が 0.01以上)
au_df = df[target_columns]
variance = au_df.var()
special_targets = [x[1] for x in zip(variance, target_columns) if x[0] > 0.01]

print(f"special_targets: {special_targets}")

# ToDo ↓これは設定ファイル化しておきたい
shiwa_map = {
    "eye": [
        1,
        2,
        4,
        5,
        6,
        7,
        9,
        41,
        42,
        43,
        44,
        45,
        46,
    ],
    "mouth": [
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        20,
        22,
        23,
        24,
        25,
        26,
        27,
        28,

    ],
    "head": [1, 2, 4, 9,],
}

# ↓特徴のあるAUのみを時系列で折れ線グラフにして表示する
for t in special_targets:
    au = df[t]
    plt.plot(au, label=t)
plt.legend()
plt.show()

# ↓累積値を計算 (口、目、おでこごとの合計を算出)
## 初期化
# this_person_map = {"eye": 0, "mouth": 0, "head": 0}
# for t in target_columns:
#     this_au_id = int(t.replace("AU", "").replace("_r", ""))
#     t_sum = sum(df[t])
#     for shiwa_part, au_list in shiwa_map.items():
#         if this_au_id in au_list:
#             this_person_map[shiwa_part] += t_sum

# print(this_person_map)
# ↑たしかこれの可視化？がまだ？

# plt.plot(this_person_map)
# plt.show()
