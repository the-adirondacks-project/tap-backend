{-# LANGUAGE TypeOperators #-}

import Control.Monad.Reader (runReaderT)
import Data.Proxy (Proxy(..))
import Database.PostgreSQL.Simple (connectPostgreSQL)
import Network.Wai (Application)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Servant (Handler, Server, (:<|>)(..), hoistServer, serve)
import Servant.API (FromHttpApiData(..))
import System.Environment (lookupEnv)
import Text.Read (readMaybe)

import Config (Config(..), ConfigM(..))
import Crik.API
import Crik.Types.Video
import Crik.Types.File
import Crik.Types.Library
import Routes.File (fileServer)
import Routes.Video (videoServer)
import Routes.VideoLibrary (videoLibraryServer)

maybeGetPort :: IO (Maybe Int)
maybeGetPort = do
  maybeRawPort <- lookupEnv "PORT"
  case maybeRawPort of
    Nothing -> return Nothing
    Just rawPort -> return (readMaybe rawPort :: Maybe Int)

getPort :: IO Int
getPort = do
  maybePort <- maybeGetPort
  case maybePort of
    Nothing -> return 8015
    Just x -> return x

getConfig :: IO Config
getConfig = do
  psqlConnection <- connectPostgreSQL ""
  return $ Config psqlConnection

api :: Proxy CrikAPI
api = Proxy

server :: Config -> Server CrikAPI
server config = hoistServer api (makeHandler config)
  (videoServer :<|> fileServer :<|> videoLibraryServer)

makeHandler config x = runReaderT (runConfigM x) config

app :: Config -> Application
app config = serve api (server config)

main :: IO ()
main = do
  -- Connection info gets passed via environment variables
  config <- getConfig
  port <- getPort
  putStrLn ("Starting server on port: " ++ (show port))
  run port (logStdoutDev (app config))
  return ()
