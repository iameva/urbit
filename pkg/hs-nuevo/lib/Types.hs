module Types where

import ClassyPrelude

import Data.Void

import qualified Data.Bimap as B
import qualified Data.Map as M


-- This entire prototype is only to show off the process model to reason about
-- whether things just deadlock. So our "vase" is just a list of text
-- fragments. Thats all you get on your typed channels.
data Vase = Vase [Text]

-- A list of path elements
data Path = Path [Text]
  deriving (Show, Eq)


-------------------------------------------------------------------------------

-- | A minimally simulated execution environment for Nuevo instances
--
-- This is not part of Nuevo proper, but is meant to be the Vere equivalent
-- which sends messages to each 
data VereEnv = VereEnv
  { instances :: M.Map Path NuevoState

  }


-------------------------------------------------------------------------------

-- | 
data Connection
  = TopConnection
  | ProcessConnection Path Int
  deriving (Show, Eq)

-- | Was: "Handle"
data Socket
  = PipeSocket
  { pipeId           :: Int
  , pipeCreator      :: Connection
  , pipeCounterparty :: Connection
  }

  | IoSocket
  { ioId     :: Int
  , ioDriver :: Text
  }

  deriving (Show, Eq)



data NuevoEvent
  = NEvInit
  { nevInitConnection :: Connection
  , nevInitName       :: Path
  , nevInitProgram    :: NuevoProgram
  , nevInitSentOver   :: Socket
  , nevInitMessage    :: Text
  }

  | NEvRecv
  { nevRecvSentOver   :: Socket
  , nevRecvMessage    :: Text
  }

data NuevoEffect
  = NEfFork
  | NEfTerminate
  deriving (Show, Eq)

-- | Each instance of 
data NuevoState = NuevoState
  { nsParent   :: Connection
  , nsName     :: Path
--  , nsChildren :: M.Map Text
  , nsProgram :: NuevoProgram
  , nsProgramState :: ProgramState
  , nsNextBone :: Int
  , nsSocketToBone :: B.Bimap Socket Int
  }

--  Processes a single Nuevo event 
type NuevoFunction = (NuevoState, NuevoEvent) -> (NuevoState, [NuevoEffect])


-------------------------------------------------------------------------------

-- Types for the program running under Nuevo

data ProgramEvent
  = PERecv
  { peRecvBone :: Int
  , peRecvMessage :: Text
  }
  deriving (Show, Eq)

data ProgramEffect
  = PESend
  { peSendBone :: Int
  , peSendMessage :: Text
  }
  deriving (Show, Eq)


-- TODO: A realer state.
type ProgramState = M.Map Text Text

-- -- The type of a program that nuevo runs.
-- type NuevoProgram = (ProgramState, ProgramEvent) -> (ProgramState, [ProgramEffect)
type NuevoProgram = (ProgramState, ProgramEvent) -> (ProgramState, [ProgramEffect])
