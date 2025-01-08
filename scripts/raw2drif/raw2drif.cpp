
#include <cstdlib>
#include <cstring>

#define DRIF_IMAGE_IMPL
#include "drif_image.h"

int main(int argc, char** argv) {
  if (argc != 6) {
    printf(
        "usage:\n\n"
        "ffmpeg -i myimage -f rawvideo -pix_fmt <pixFormat> <image.raw>\n"
        "%s <width> <height> <pixFormat> <image.raw> <out.drif>\n",
        argv[0]);
    return 1;
  }
  const int width = atoi(argv[1]);
  const int height = atoi(argv[2]);
  const char* pixFmt = argv[3];
  const char* inPath = argv[4];
  const char* outPath = argv[5];

  struct dataFormats {
    const char* ffName;  // ffmpeg name
    int format;          // our name
  } formats[] = {
      {"bgr24", DRIF_FMT_BGR888},    {"rgb24", DRIF_FMT_RGB888},
      {"bgrp", DRIF_FMT_BGR888P},    {"rgbp", DRIF_FMT_RGB888P},
      {"bgra", DRIF_FMT_BGRA8888},   {"rgba", DRIF_FMT_RGBA8888},
      {"bgrap", DRIF_FMT_BGRA8888P}, {"rgbap", DRIF_FMT_RGBA8888P},
      {"gray", DRIF_FMT_GRAY},       {"yuv420p", DRIF_FMT_YUV420P},
      {"yvu420p", DRIF_FMT_YVU420P}, {"nv12", DRIF_FMT_NV12},
      {"nv21", DRIF_FMT_NV21},
  };

  int fmt = -1;
  for (auto& f : formats)
    if (strcmp(f.ffName, pixFmt) == 0) {
      fmt = f.format;
      break;
    }

  if (fmt < 0) {
    printf("%s: unsupported pixel format: %s\n", argv[0], pixFmt);
    return 2;
  }

  FILE* fp = fopen(inPath, "rb");
  void* buffer = malloc(drifGetSize(width, height, fmt));
  fread(buffer, drifGetSize(width, height, fmt), 1, fp);

  drifSaveImg(outPath, width, height, fmt, buffer);

  return 0;
}
