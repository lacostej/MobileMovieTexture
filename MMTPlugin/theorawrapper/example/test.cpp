#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "theorawrapper.h"
#include <time.h>
#include <sys/time.h>

int main(int argc, char* argv[])
{
  char* path = NULL;
  if (argc < 1) {
    std::cerr << "Usage: " << argv[0] << " NAME" << std::endl;
    return 1;
  }
  path = argv[1];

  //std::cout << std::endl << "Checking ogv file " << path << std::endl;

  PlaybackState* m_nativeContext = (PlaybackState*) CreateContext();
  
  if (m_nativeContext != NULL) {
    int offset = 0;
    int length = 0;
    bool powerOf2Textures = false;
    bool m_scanDuration = false;
    int maxSkipFrames = 16;

    timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);

    if (OpenStream(m_nativeContext, path, (int)offset, (int)length, powerOf2Textures, m_scanDuration, maxSkipFrames)) {
      int Width = GetPicWidth(m_nativeContext);
      int Height = GetPicHeight(m_nativeContext);

      int m_picX = GetPicX(m_nativeContext);
      int m_picY = GetPicY(m_nativeContext);

      int m_yStride = GetYStride(m_nativeContext);
      int m_yHeight = GetYHeight(m_nativeContext);
      int m_uvStride = GetUVStride(m_nativeContext);
      int m_uvHeight = GetUVHeight(m_nativeContext);

      std::cout << "Width=" << Width << " Height=" << Height;
      std::cout << " m_picX=" << m_picX << " m_picY=" << m_picY << std::endl;

      std::cout << "m_yStride=" << m_yStride << " m_yHeight=" << m_yHeight;
      std::cout << " m_uvStride=" << m_uvStride << " m_uvHeight=" << m_uvHeight << std::endl;     

      void* previousTextureContext = NULL;
      do {
        void* textureContext = GetNativeTextureContext(m_nativeContext);
        if (textureContext != previousTextureContext) {
          std::cout << "Changed texture Context" << std::endl;
          previousTextureContext = textureContext;
        }
        std::cout << "FrameTime: " << GetDecodedFrameTime(m_nativeContext) << std::endl;

        UploadReadyPlaybackStates();

        bool hasFinished = HasFinished(m_nativeContext);

        if (hasFinished) break;

        // here add some random
        struct timespec req, rem;
        req.tv_sec  = 0;
        req.tv_nsec = 100000000L + 100000000ULL * rand() / RAND_MAX; // between 0.1 and 0.2 s
        std::cout << "Sleeping: " << req.tv_nsec << " ns" << std::endl;
        nanosleep(&req, &rem);

        hasFinished = HasFinished(m_nativeContext);

        if (hasFinished) break;

        timespec now;
        clock_gettime(CLOCK_REALTIME, &now);
        printf("B4  %lld.%.9ld\n", (long long)ts.tv_sec, ts.tv_nsec);
        printf("NOW %lld.%.9ld\n", (long long)now.tv_sec, now.tv_nsec);

        double elapsed = (now.tv_sec - ts.tv_sec) + (now.tv_nsec - ts.tv_nsec) * 1.0 / 1000000000L;

        SetTargetDisplayDecodeTime(m_nativeContext, elapsed);

      } while (true);

      CloseStream(m_nativeContext);
    }
  }
  DestroyContext(m_nativeContext);
}

