def main():
    result = 0

    f = open("input.txt", "r")
    content = f.read()
    f.close()
    lines = content.split("\n")
    for line in lines:
        firstDigit = ""
        lastDigit = ""
        if line == "":
            continue
        for c in line:
            if c >= "0" and c <= "9":
                firstDigit = c
                break
        linelen = len(line)
        for idx in range(linelen - 1, -1, -1):
            c = line[idx]
            if c >= "0" and c <= "9":
                lastDigit = c
                break
        result = result + int(firstDigit + lastDigit)

    print(result)


if __name__ == "__main__":
    print("---------------")
    main()
