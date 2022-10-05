String beautifulString(String str) => str
    .split(RegExp(r'(?=[A-Z])'))
    .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
    .join(" ");
