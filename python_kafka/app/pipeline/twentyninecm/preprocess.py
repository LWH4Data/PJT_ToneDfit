import json
import os


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
product_list_path = f"{BASE_DIR}/raw_data.json"

with open(product_list_path, "r", encoding="utf-8") as f:
    product_image_map = json.load(f)

print(len(product_image_map))
# new_data = []

# for i in range(1, 48):
#     raw_data_path = f"{BASE_DIR}/2025-10-29/raw_data/29cm_data_{i}.json"

#     with open(raw_data_path, "r", encoding="utf-8") as f:
#         raw_data = json.load(f)

#     # # 데이터 업데이트
#     # for item in raw_data:
#     #     pid = str(item.get("product_id"))
#     #     if pid in product_image_map:
#     #         item["representative_image_url"] = product_image_map[pid]

#     for item in raw_data:
#         image = item.get("representative_image_url")
#         if image:
#             new_data.append(item)

#     print(f"Processed file {raw_data_path}")

# # 저장
# with open(f"{BASE_DIR}/raw_data.json", "w", encoding="utf-8") as f:
#     json.dump(new_data, f, ensure_ascii=False, indent=2)

# print(f"Updated file saved {raw_data_path}")
