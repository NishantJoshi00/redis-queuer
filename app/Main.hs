{-# LANGUAGE LambdaCase #-}
module Main where

import Database.Redis.Redis;
import Control.Monad (when);
import Control.Concurrent (threadDelay)
import Control.Parallel.Strategies (rpar, runEval)
import GHC.Conc (forkIO)

-- Functions for Flow 1
hostStack :: Redis -> Int -> Int -> Int -> IO Int
hostStack conn size 0 from = return from
hostStack conn size count from = sadd conn "key:store" (show from ++ ":" ++ show (from + size - 1)) >>= 
  \case
    RInt va -> do
      -- print va
      hostStack conn size (count - va) (from + size)
    _ -> return from

fillSetTank :: Redis -> Int -> (Int -> Int -> IO Int) -> Int -> IO Int
fillSetTank conn capacity func from = scard conn "key:store" >>=
  \case
    RInt size -> if size >= capacity then return from else func (capacity - size) from
    _ -> return from

loopFillTank :: Int -> (Int -> IO Int) -> Int -> IO ()
loopFillTank end func start = do
  threadDelay 20000
  when (end > start) $ func start >>= loopFillTank end func






-- Functions for Flow 2
splitStrs :: Char -> String -> String -> (String, String)
splitStrs dlm "" right = ("", right)
splitStrs dlm left right = do
  let lrest = init left
  let split = last left
  if split == dlm then (lrest, right)
  else splitStrs dlm lrest (split:right)

strToNums :: (String, String) -> (Int, Int)
strToNums (v1, v2) = do
  (read v1, read v2)

writeDownRedis :: Redis -> String -> IO ()
writeDownRedis conn name = do
  content <- hget conn "dump:store" name
  case content of
    RBulk (Just value) -> do
      writeFile (name ++ ".json") value
      value <- hdel conn "dump:store" name
      case value of
        RInt v -> return ()
        _ -> return ()
    _ -> return ()



dumperBoi :: Redis -> Int -> [String] -> IO ()
dumperBoi _ _ [] = return ()
dumperBoi conn span (x:xs) = do
  let (l, r) = strToNums $ splitStrs ':' x ""
  when ((r - l) == span) $ writeDownRedis conn x
  dumperBoi conn span xs

unwrapReply :: [Reply String] -> [String]
unwrapReply [] = []
unwrapReply (reply:replies) = do
  case reply of
    RBulk (Just inner) -> inner : unwrapReply replies
    _ -> unwrapReply replies

getHKeys :: Redis -> String -> IO [String]
getHKeys conn key = do
  value <- hkeys conn key
  case value of
    RMulti (Just arr) -> do
      return $ unwrapReply arr
    _ -> return []


checkRangers :: Redis -> Int -> IO ()
checkRangers conn span = do
  _ <- threadDelay 20000
  getHKeys conn "dump:store" >>= dumperBoi conn span
  checkRangers conn span




-- Execution Point
main :: IO ()
main = do
  conn <- connect localhost defaultPort
  tid <- forkIO (loopFillTank 250 (fillSetTank conn count $ hostStack conn stack_size) from)
  checkRangers conn (count - 1)
  disconnect conn
  where
    from = 0
    count = 10
    stack_size = 10