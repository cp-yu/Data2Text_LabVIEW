def ToText(list_a, list_b, title, extra_info, col_names):
    with open(title, 'w') as file:
        # 写入额外信息
        file.write(extra_info + '\n')
        # 写入列名
        file.write(f"{col_names[0]}\t{col_names[1]}\n")
        # 写入数据
        min_len = min(len(list_a), len(list_b))
        for i in range(min_len):
            file.write(f"{list_a[i]}\t{list_b[i]}\n")
if __name__ == "__main__":
    list_a = [1, 2, 3]
    list_b = [4, 5, 6]
    title = "output.txt"
    extra_info = "这是额外信息"
    col_names = ["列A", "列B"]

    ToText(list_a, list_b, title, extra_info, col_names)
