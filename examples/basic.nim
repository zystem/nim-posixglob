import posixglob

if globMatch("*.nim", "main.nim"):
  echo "match"
else:
  echo "no match"
