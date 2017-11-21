{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module API
(
  API
, VideoAPI
, VideoLibraryAPI
, NewFiles
, AllFiles
) where

import Data.Text (Text)
import Servant.API (Capture, Get, JSON, Post, Put, ReqBody, (:>), (:<|>)((:<|>)))

import Types.Video (NoId, Video, VideoId)
import Types.VideoFile (VideoFile, VideoFileId)
import Types.VideoLibrary (VideoLibrary, VideoLibraryId)

type API = VideoAPI :<|> VideoLibraryAPI

type VideoAPI = "videos" :> (
    Get '[JSON] [Video VideoId] :<|>
    ReqBody '[JSON] (Video NoId) :> Post '[JSON] (Video VideoId) :<|>
    Capture "videoId" Int :> ReqBody '[JSON] (Video NoId) :> Put '[JSON] (Video VideoId) :<|>
    Capture "videoId" Int :> Get '[JSON] (Video VideoId) :<|>
    Capture "videoId" Int :> "files" :> Get '[JSON] [VideoFile] :<|>
    Capture "videoId" Int :> "files" :> Capture "videoFileId" Int :> Get '[JSON] VideoFile :<|>
    "files" :> (
      Get '[JSON] [VideoFile] :<|>
      Capture "videoFileId" Int :> Get '[JSON] VideoFile
    )
  )

type VideoLibraryAPI =
    "video_libraries" :> Get '[JSON] [VideoLibrary] :<|>
    "video_libraries" :> Capture "videoLibraryId" Int :> Get '[JSON] VideoLibrary :<|>
    NewFiles :<|>
    AllFiles

type NewFiles = "video_libraries" :> Capture "videoLibraryId" Int :> "new_files" :> Get '[JSON] [Text]
type AllFiles = "video_libraries" :> Capture "videoLibraryId" Int :> "all_files" :> Get '[JSON] [Text]
