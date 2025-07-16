#!/bin/bash

set -e

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: ./init_project.sh <project_name> <language: c|cpp|python>"
    exit 1
fi

project_name="$1"
language="$2"

create_structure(){
    mkdir -p "$project_name"/{src,include,docs,build,scripts}
    touch "$project_name/README.md"
}

setup_language_files() {
    case "$language" in 
        c)
            # Create main.c in src/
cat > "$project_name/src/main.c" <<EOF
#include <stdio.h>
int main() {
    printf("Hello, C Project!\\n");
    return 0;
} 
EOF

cat > "$project_name/Makefile" <<EOF
CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
SRC = \$(wildcard src/*.c)
OBJ = \$(SRC:.c=.o)
main: \$(OBJ)
	\$(CC) \$(CFLAGS) -o build/main \$(OBJ)
clean:
	rm -f src/*.o build/main
EOF

            ;;

        cpp)
            # Create main.cpp in src/
cat > "$project_name/src/main.cpp" <<EOF
#include <iostream>
int main() {
    std::cout << "Hello, C++ Project!" << std::endl;
    return 0;
}
EOF
cat > "$project_name/Makefile" <<EOF
CXX = g++
CXXFLAGS = -Wall -Wextra -Iinclude
SRC = \$(wildcard src/*.cpp)
OBJ = \$(SRC:.cpp=.o)
main: \$(OBJ)
	\$(CXX) \$(CXXFLAGS) -o build/main \$(OBJ)
clean:
	rm -f src/*.o build/main
EOF

            ;;
        python)

cat > "$project_name/src/main.py" <<EOF
def main():
    print("Hello, Python Project!")
if __name__ == "__main__":
    main()
EOF

# Create a virtual environment in the project root
python3 -m venv "$project_name/venv"

echo "✅ Virtual environment created at $project_name/venv"
echo "👉 To activate it: source $project_name/venv/bin/activate"
            ;;
    esac
}

setup_doxygen() {
    echo "📝 Setting up Doxygen for $project_name..."

    # Generate a default Doxygen config
    doxygen -g "$project_name/docs/Doxyfile"

    doxyfile="$project_name/docs/Doxyfile"

    # Replace key values using sed
    sed -i "s|^PROJECT_NAME .*|PROJECT_NAME = \"$project_name\"|" "$doxyfile"
    sed -i "s|^OUTPUT_DIRECTORY .*|OUTPUT_DIRECTORY = docs|" "$doxyfile"
    sed -i "s|^INPUT .*|INPUT = src include|" "$doxyfile"
    sed -i "s|^RECURSIVE .*|RECURSIVE = YES|" "$doxyfile"
    sed -i "s|^EXCLUDE .*|EXCLUDE = build scripts tests|" "$doxyfile"
    sed -i "s|^INLINE_SOURCES .*|INLINE_SOURCES = YES|" "$doxyfile"
    sed -i "s|^SOURCE_BROWSER .*|SOURCE_BROWSER = YES|" "$doxyfile"
    sed -i "s|^USE_MDFILE_AS_MAINPAGE .*|USE_MDFILE_AS_MAINPAGE = README.md|" "$doxyfile"

    echo "✅ Doxygen configured at $doxyfile"
}


create_structure
setup_language_files

if [[ "$language"="cpp" || "$language"="c" ]]; then
   setup_doxygen 
fi
