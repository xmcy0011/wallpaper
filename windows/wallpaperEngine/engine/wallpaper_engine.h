/****************************************************************************************************
wallpaper_engine.h
  wallpaper_engine header file.
  Copyright (c) StarLeap Studio.(2026), All rights reserved.

Purpose:
  Header file to implement wallpaper_engine.

Author:
  Jake (xmcy0011@gmail.com)

Creating Time:
  2026-02-26
****************************************************************************************************/
#ifndef WALLPAPER_ENGINE_H_
#define WALLPAPER_ENGINE_H_

#include <string>
#include <functional>
#include <windows.h>

namespace engine {
using LoadedCallback = std::function<void()>;
using ExitedCallback = std::function<void()>;

class IWallpaperEngine {
public:
  virtual ~IWallpaperEngine() = default;

  virtual bool Initialize() = 0;
  virtual bool IsInitialized() const = 0;
  virtual bool LoadMedia(const std::wstring &filePath) = 0;
  virtual void SetBounds(int x, int y, int width, int height) = 0;
  
  virtual void Play() = 0;
  virtual void Pause() = 0;
  virtual void Close() = 0;
  
  virtual HWND GetWindowHandle() const = 0;
  virtual bool IsLoaded() const = 0;
  virtual bool IsExited() const = 0;

  virtual void SetLoadedCallback(LoadedCallback cb) = 0;
  virtual void SetExitedCallback(ExitedCallback cb) = 0;
};

} // namespace engine

#endif // WALLPAPER_ENGINE_H_