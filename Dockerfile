FROM ghcr.io/xu-cheng/texlive-full:latest

RUN --mount=type=bind,source=./fetch_fonts.py,target=/fetch_fonts.py \
    python3 /fetch_fonts.py
