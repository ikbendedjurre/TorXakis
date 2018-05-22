{-
TorXakis - Model Based Testing
Copyright (c) 2015-2017 TNO and Radboud University
See LICENSE at root directory of this repository.
-}

-----------------------------------------------------------------------------
-- |
-- Module      :  TxsTest
-- Copyright   :  TNO and Radboud University
-- License     :  BSD3
-- Maintainer  :  jan.tretmans
-- Stability   :  experimental
--
-- Core Module TorXakis API:
-- Testing Mode
-----------------------------------------------------------------------------

-- {-# LANGUAGE OverloadedStrings #-}
-- {-# LANGUAGE ViewPatterns        #-}

module TxsCore

( -- * set up TorXakis core
  txsSetCore

  -- * initialize TorXakis core
, txsInitCore

  -- * terminate TorXakis core
, txsTermitCore

{-

  -- * Mode
  -- ** start testing
, txsSetTest

  -- *** test Input Action
, txsTestIn

  -- *** test Output Action
, txsTestOut

  -- *** test number of Actions
, txsTestN

  -- ** start simulating
, txsSetSim

  -- *** simulate number of Actions
, txsSimN

  -- ** stop stepping
, txsStopNW

  -- ** stop testing, simulating
, txsStopEW

-}
  -- *  TorXakis definitions loaded into the core.
, txsGetTDefs
, txsGetSigs
, txsGetCurrentModel
{-
  -- ** set all torxakis definitions
, txsSetTDefs


  -- * Parameters
  -- ** get all parameter values
, txsGetParams

  -- ** get value of parameter
, txsGetParam

  -- ** set value of parameter
, txsSetParam

  -- * set random seed
, txsSetSeed

-}

  -- * evaluation of value expression
, txsEval

{-

  -- * Solving
  -- ** finding a solution for value expression
, txsSolve

  -- ** finding an unique solution for value expression
, txsUniSolve

  -- ** finding a random solution for value expression
, txsRanSolve

  -- * show item
, txsShow


  -- * give path
, txsPath


  -- * give menu
, txsMenu


  -- * give action to mapper
, txsMapper

  -- * test purpose for N complete coverage
, txsNComp

  -- * LPE transformation
, txsLPE

-}

)

-- ----------------------------------------------------------------------------------------- --
-- import

where

-- import           Control.Arrow
-- import           Control.Monad
-- import           Control.Monad.State
-- import qualified Data.List           as List
-- import qualified Data.Map            as Map
-- import           Data.Maybe
-- import           Data.Monoid
-- import qualified Data.Set            as Set
-- import qualified Data.Text           as T
-- import           System.IO
-- import           System.Random

-- import from local
-- import           CoreUtils
-- import           Ioco
-- import           Mapper
-- import           NComp
-- import           Purpose
-- import           Sim
-- import           Step
-- import           Test

-- import           Config              (Config)
-- import qualified Config

-- import from behave(defs)
-- import qualified Behave
-- import qualified BTree
-- import           Expand              (relabel)

-- import from coreenv
-- import           EnvCore             (modeldef)
-- import qualified EnvCore             as IOC
-- import qualified EnvData
-- import qualified ParamCore

-- import from defs
-- import qualified Sigs
-- import qualified TxsDDefs
-- import qualified TxsDefs
-- import qualified TxsShow
-- import           TxsUtils
-- 
-- import from solve
-- import qualified FreeVar
-- import qualified SMT
-- import qualified Solve
-- import qualified Solve.Params
-- import qualified SolveDefs
-- import qualified SMTData

-- import from value
-- import qualified Eval

-- import from lpe
-- import qualified LPE
-- import qualified LPE

-- import from valexpr
-- import qualified SortId
-- import qualified SortOf
-- import           ConstDefs
-- import           VarId


-- ----------------------------------------------------------------------------------------- --
-- | Set Testing Mode.
--
--   Only possible when in Initing Mode.
txsSetTest :: IOC.EWorld ew
           => D.ModelDef                           -- ^ model definition.
           -> Maybe D.MapperDef                    -- ^ optional mapper definition.
           -> ew                                   -- ^ external world.
           -> IOC.IOC (Either EnvData.Msg ())
txsSetTest moddef mapdef eworld  =  do
     envc <- get
     case IOC.state envc of
       IOC.Initing { IOC.smts      = smts
                   , IOC.tdefs     = tdefs
                   , IOC.sigs      = sigs
                   , IOC.putmsgs  = putmsgs
                   }
         -> do IOC.putCS IOC.TestSet { IOC.smts      = smts
                                     , IOC.tdefs     = tdefs
                                     , IOC.sigs      = sigs
                                     , IOC.modeldef  = moddef
                                     , IOC.mapperdef = mapdef
                                     , IOC.eworld    = eworld
                                     , IOC.putmsgs   = putmsgs
               Right <$> putmsgs [ EnvData.TXS_CORE_USER_INFO
                                   "Testing Mode set" ]
       _ -> return $ Left $ EnvData.TXS_CORE_USER_ERROR
                            "Testing Mode must be set from Initing mode"

-- ----------------------------------------------------------------------------------------- --
-- | Shut Testing Mode.
--
--   Only possible when in TestSet Mode.
txsShutTest :: IOC.IOC (Either EnvData.Msg ())
txsShutTest  =  do
     envc <- get
     case IOC.state envc of
       IOC.TestSet { IOC.smts      = smts
                   , IOC.tdefs     = tdefs
                   , IOC.sigs      = sigs
                   , IOC.modeldef  = _moddef
                   , IOC.mapperdef = _mapdef
                   , IOC.eworld    = _eworld
                   , IOC.putmsgs   = putmsgs
                   }
         -> do IOC.putCS IOC.Initing { IOC.smts     = smts
                                     , IOC.tdefs    = tdefs
                                     , IOC.sigs     = sigs
                                     , IOC.putmsgs  = putmsgs
                                     }
               Right <$> putmsgs [ EnvData.TXS_CORE_USER_INFO
                                   "Testing Mode shut" ]
       _ -> return $ Left $ EnvData.TXS_CORE_USER_ERROR
                            "Testing Mode must be shut from TestSet Mode"

-- ----------------------------------------------------------------------------------------- --
-- | Start testing.
--
--   Only possible when in TestSet Mode.
txsStartTest :: Maybe D.PurpDef                    -- ^ optional test purpose definition.
             -> IOC.IOC (Either EnvData.Msg ())
txsStartTest purpdef  =  do
     envc <- get
     case IOC.state envc of
       IOC.TestSet { IOC.smts      = smts
                   , IOC.tdefs     = tdefs
                   , IOC.sigs      = sigs
                   , IOC.modeldef  = moddef
                   , IOC.mapperdef = mapdef
                   , IOC.eworld    = eworld
                   , IOC.putmsgs   = putmsgs
                   }
         -> do IOC.putCS IOC.Testing { IOC.smts      = smts
                                     , IOC.tdefs     = tdefs
                                     , IOC.sigs      = sigs
                                     , IOC.modeldef  = moddef
                                     , IOC.mapperdef = mapdef
                                     , IOC.purpdef   = purpdef
                                     , IOC.eworld    = eworld
                                     , IOC.behtrie   = []
                                     , IOC.inistate  = 0
                                     , IOC.curstate  = 0
                                     , IOC.modsts    = []
                                     , IOC.mapsts    = []
                                     , IOC.purpsts   = []
                                     , IOC.putmsgs   = putmsgs
                                     }

               (maybt,mt,gls) <- startTester moddef mapdef purpdef
               case maybt of
                 Nothing
                   -> Right <$> putmsgs [ EnvData.TXS_CORE_SYSTEM_INFO
                                          "Starting Testing Mode failed" ]
                 Just bt
                   -> do eWorld' <- IOC.startW eWorld
                         IOC.putCS IOC.Testing { IOC.smts      = smts
                                               , IOC.tdefs     = tdefs
                                               , IOC.sigs      = sigs
                                               , IOC.modeldef  = moddef
                                               , IOC.mapperdef = mapdef
                                               , IOC.purpdef   = purpdef
                                               , IOC.eworld    = eWorld'
                                               , IOC.behtrie   = []
                                               , IOC.inistate  = 0
                                               , IOC.curstate  = 0
                                               , IOC.modsts    = bt
                                               , IOC.mapsts    = mt
                                               , IOC.purpsts   = fmap (second Left) gls
                                               , IOC.putmsgs   = putmsgs
                                               }
                         unless
                           (null gls)
                           (IOC.putMsgs [ EnvData.TXS_CORE_USER_INFO $ "Goals: " ++
                                          List.intercalate "," (TxsShow.fshow . fst <$> gls) ])
                         IOC.putMsgs [ EnvData.TXS_CORE_USER_INFO "Tester started" ]
                         return eWorld'
       _ -> do                        -- IOC.Idling, IOC.Testing, IOC.Simuling, IOC.Stepping --
               IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester must start in Initing mode" ]
               return eWorld


startTester :: D.ModelDef
            -> Maybe D.MapperDef
            -> Maybe D.PurpDef
            -> IOC.IOC ( Maybe BTree.BTree, BTree.BTree, [(D.GoalId,BTree.BTree)] )

startTester (D.ModelDef minsyncs moutsyncs msplsyncs mbexp)
            Nothing
            Nothing  =
     let allSyncs = minsyncs ++ moutsyncs ++ msplsyncs
     in do
       envb            <- filterEnvCtoEnvB
       (maybt', envb') <- lift $ runStateT (Behave.behInit allSyncs mbexp) envb
       writeEnvBtoEnvC envb'
       return ( maybt', [], [] )

startTester (D.ModelDef  minsyncs moutsyncs msplsyncs mbexp)
            (Just (D.MapperDef achins achouts asyncsets abexp))
            Nothing  =
     let { mins  = Set.fromList minsyncs
         ; mouts = Set.fromList moutsyncs
         ; ains  = Set.fromList $ filter (not . Set.null)
                       [ sync `Set.intersection` Set.fromList achins  | sync <- asyncsets ]
         ; aouts = Set.fromList $ filter (not . Set.null)
                       [ sync `Set.intersection` Set.fromList achouts | sync <- asyncsets ]
         }
      in if     mins  `Set.isSubsetOf` ains
             && mouts `Set.isSubsetOf` aouts
           then do let allSyncs = minsyncs ++ moutsyncs ++ msplsyncs
                   envb            <- filterEnvCtoEnvB
                   (maybt',envb' ) <- lift $ runStateT (Behave.behInit allSyncs  mbexp) envb
                   (maymt',envb'') <- lift $ runStateT (Behave.behInit asyncsets abexp) envb'
                   writeEnvBtoEnvC envb''
                   case (maybt',maymt') of
                     (Nothing , _       ) -> do
                          IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester model failed" ]
                          return ( Nothing, [], [] )
                     (_       , Nothing ) -> do
                          IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester mapper failed" ]
                          return ( Nothing, [], [] )
                     (Just _, Just mt') ->
                          return ( maybt', mt', [] )
           else do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Inconsistent definitions" ]
                   return ( Nothing, [], [] )

startTester (TxsDefs.ModelDef minsyncs moutsyncs msplsyncs mbexp)
            Nothing
            (Just (TxsDefs.PurpDef pinsyncs poutsyncs psplsyncs goals))  =
     let { mins   = Set.fromList minsyncs
         ; mouts  = Set.fromList moutsyncs
         ; pins   = Set.fromList pinsyncs
         ; pouts  = Set.fromList poutsyncs
         }
      in if     ( (pins  == Set.empty) || (pins  == mins)  )
             && ( (pouts == Set.empty) || (pouts == mouts) )
           then do let allSyncs  = minsyncs ++ moutsyncs ++ msplsyncs
                       pAllSyncs = pinsyncs ++ poutsyncs ++ psplsyncs
                   envb           <- filterEnvCtoEnvB
                   (maybt',envb') <- lift $ runStateT (Behave.behInit allSyncs mbexp) envb
                   writeEnvBtoEnvC envb'
                   case maybt' of
                     Nothing -> do
                          IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester model failed" ]
                          return ( Nothing, [], [] )
                     Just _ -> do
                          gls <- mapM (goalInit pAllSyncs) goals
                          return ( maybt', [], concat gls )
           else do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Inconsistent definitions" ]
                   return ( Nothing, [], [] )

startTester (TxsDefs.ModelDef  minsyncs moutsyncs msplsyncs mbexp)
            (Just (TxsDefs.MapperDef achins achouts asyncsets abexp))
            (Just (TxsDefs.PurpDef pinsyncs poutsyncs psplsyncs goals))  =
     let { mins  = Set.fromList minsyncs
         ; mouts = Set.fromList moutsyncs
         ; ains  = Set.fromList $ filter (not . Set.null)
                       [ sync `Set.intersection` Set.fromList achins  | sync <- asyncsets ]
         ; aouts = Set.fromList $ filter (not . Set.null)
                       [ sync `Set.intersection` Set.fromList achouts | sync <- asyncsets ]
         ; pins  = Set.fromList pinsyncs
         ; pouts = Set.fromList poutsyncs
         }
      in if     ( (pins  == Set.empty) || (pins  == mins)  )
             && ( (pouts == Set.empty) || (pouts == mouts) )
             && mins  `Set.isSubsetOf` ains
             && mouts `Set.isSubsetOf` aouts
           then do let allSyncs  = minsyncs ++ moutsyncs ++ msplsyncs
                       pAllSyncs = pinsyncs ++ poutsyncs ++ psplsyncs
                   envb            <- filterEnvCtoEnvB
                   (maybt',envb')  <- lift $ runStateT (Behave.behInit allSyncs  mbexp) envb
                   (maymt',envb'') <- lift $ runStateT (Behave.behInit asyncsets abexp) envb'
                   writeEnvBtoEnvC envb''
                   case (maybt',maymt') of
                     (Nothing , _       ) -> do
                          IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester model failed" ]
                          return ( Nothing, [], [] )
                     (_       , Nothing ) -> do
                          IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester mapper failed" ]
                          return ( Nothing, [], [] )
                     (Just _, Just mt') -> do
                          gls <- mapM (goalInit pAllSyncs) goals
                          return ( maybt', mt', concat gls )
           else do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Inconsistent definitions" ]
                   return ( Nothing, [], [] )

goalInit :: [ Set.Set TxsDefs.ChanId ] ->
            (TxsDefs.GoalId,TxsDefs.BExpr) ->
            IOC.IOC [(TxsDefs.GoalId,BTree.BTree)]
goalInit chsets (gid,bexp)  =  do
     envb           <- filterEnvCtoEnvB
     (maypt',envb') <- lift $ runStateT (Behave.behInit chsets bexp) envb
     writeEnvBtoEnvC envb'
     return $ case maypt' of
              { Nothing  -> []
              ; Just pt' -> [ (gid, pt') ]
              }


-- ----------------------------------------------------------------------------------------- --
-- | Stop testing.
--








-- | stop testing, simulating, or stepping.
-- returns txscore to the initialized state, when no External World running.
-- See 'txsSetStep'.
txsStopNOEW :: IOC.IOC ()
txsStopNOEW  =  do
     envc <- get
     let cState = IOC.state envc
     case cState of
       IOC.Stepping { }
         -> do put envc { IOC.state = IOC.Initing { IOC.smts    = IOC.smts    cState
                                                  , IOC.tdefs   = IOC.tdefs   cState
                                                  , IOC.sigs    = IOC.sigs    cState
                                                  , IOC.putmsgs = IOC.putmsgs cState
                        }                         }
               IOC.putMsgs [ EnvData.TXS_CORE_USER_INFO "Stepping stopped" ]
       _ -> do                         -- IOC.Idling, IOC.Initing IOC.Testing, IOC.Simuling --
               IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "txsStopNW only in Stepping mode" ]


-- | stop testing, simulating.
-- returns txscore to the initialized state, when External World running.
-- See 'txsSetTest', 'txsSetSim', respectively.
txsStopEW :: (IOC.EWorld ew)
          => ew                                         -- ^ external world.
          -> IOC.IOC ew                                 -- ^ modified external world.
txsStopEW eWorld  =  do
     envc <- get
     let cState = IOC.state envc
     case cState of
       IOC.Testing { }
         -> do put envc { IOC.state = IOC.Initing { IOC.smts    = IOC.smts    cState
                                                  , IOC.tdefs   = IOC.tdefs   cState
                                                  , IOC.sigs    = IOC.sigs    cState
                                                  , IOC.putmsgs = IOC.putmsgs cState
                        }                         }
               eWorld' <- IOC.stopW eWorld
               IOC.putMsgs [ EnvData.TXS_CORE_USER_INFO "Testing stopped" ]
               return eWorld'
       IOC.Simuling { }
         -> do put envc { IOC.state = IOC.Initing { IOC.smts    = IOC.smts    cState
                                                  , IOC.tdefs   = IOC.tdefs   cState
                                                  , IOC.sigs    = IOC.sigs    cState
                                                  , IOC.putmsgs = IOC.putmsgs cState
                        }                         }
               eWorld' <- IOC.stopW eWorld
               IOC.putMsgs [ EnvData.TXS_CORE_USER_INFO "Simulation stopped" ]
               return eWorld'
       _ -> do                         -- IOC.Idling, IOC.Initing IOC.Testing, IOC.Simuling --
               IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR
                             "txsStopEW only in Testing or Simuling mode" ]
               return eWorld

-}

-- | Get the TorXakis definitions that were loaded into the core.
txsGetTDefs :: IOC.IOC TxsDefs.TxsDefs
txsGetTDefs =  do
     envc <- get
     case IOC.state envc of
         IOC.Idling ->
             return TxsDefs.empty
         _  ->
             return $ IOC.tdefs (IOC.state envc)

-- | Get the TorXakis signatures that were loaded into the core.
txsGetSigs :: IOC.IOC (Sigs.Sigs VarId)
txsGetSigs =  do
    envc <- get
    case IOC.state envc of
         IOC.Idling ->
             return Sigs.empty
         _  ->
             return $ IOC.sigs (IOC.state envc)

-- | Get the current model, if any. A model will be returned only in the
-- 'Testing', 'Simuling', 'StepSet', and 'Stepping' modes.
txsGetCurrentModel :: IOC.IOC (Maybe TxsDefs.ModelDef)
txsGetCurrentModel = do
    envc <- get
    case IOC.state envc of
        IOC.Idling                  -> return Nothing
        IOC.Initing {}              -> return Nothing
        IOC.ManSet {}               -> return Nothing
        IOC.Manualing {}            -> return Nothing
        -- Please note that we want to have an *explicit* pattern matching on
        -- the constructors that have a model definition, since we don't want
        -- to inadvertently try to access a value that does not have a modeldef
        -- field if `CoreState` gets extended later on.
        IOC.Testing {modeldef = m}  -> return (Just m)
        IOC.Simuling {modeldef = m} -> return (Just m)
        IOC.StepSet {modeldef = m}  -> return (Just m)
        IOC.Stepping {modeldef = m} -> return (Just m)

{-

-- | Set all torxakis definitions
txsSetTDefs :: TxsDefs.TxsDefs -> IOC.IOC ()
txsSetTDefs tdefs'  =  do
     envc <- get
     case IOC.state envc of
       IOC.Idling -> return ()
       _                             -- IOC.Initing, IOC.Testing, IOC.Simuling, IOC.Stepping --
                  -> IOC.modifyCS $ \st -> st { IOC.tdefs = tdefs' }

-- | Get the values of all parameters.
txsGetParams :: IOC.IOC [(String,String)]
txsGetParams  =
     IOC.getParams []

-- | Get the value of the provided parameter.
txsGetParam :: String                       -- ^ name of the parameter.
            -> IOC.IOC [(String,String)]
txsGetParam prm  =
     IOC.getParams [prm]

-- | Set the provided parameter to the provided value.
txsSetParam :: String                       -- ^ name of the parameter.
            -> String                       -- ^ new value for the parameter.
            -> IOC.IOC [(String,String)]
txsSetParam prm val  =
     IOC.setParams [(prm,val)]

-- | Set the random seed to the provided value.
txsSetSeed :: Int                           -- ^ new value for seed.
           -> IOC.IOC ()
txsSetSeed seed  =  do
     lift $ setStdGen(mkStdGen seed)
     IOC.putMsgs [ EnvData.TXS_CORE_SYSTEM_INFO $ "Seed set to " ++ show seed ]

-}

-- | Evaluate the provided value expression.
--
--   Only possible when txscore is initialized.
txsEval :: TxsDefs.VExpr                    -- ^ value expression to be evaluated.
        -> IOC.IOC (Either String Const)
txsEval vexp  =  do
     envc <- get
     case IOC.state envc of
       IOC.Idling
         -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "No 'eval' without model" ]
               return $ Left "No 'eval' without model"
       _ -> let frees = FreeVar.freeVars vexp
            in if  not $ null frees
                     then do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR
                                           $ "Value expression not closed: " ++
                                             TxsShow.fshow frees ]
                             return $ Left $ "Value expression not closed: " ++
                                             TxsShow.fshow frees
                     else do envb         <- filterEnvCtoEnvB
                             (wal',envb') <- lift $ runStateT (Eval.eval vexp) envb
                             writeEnvBtoEnvC envb'
                             return wal'

{-

-- | Find a solution for the provided Boolean value expression.
--
--   Only possible when txscore is initialized.
txsSolve :: TxsDefs.VExpr                   -- ^ value expression to solve.
         -> IOC.IOC (TxsDefs.WEnv VarId)
txsSolve vexp  =  do
     envc <- get
     case IOC.state envc of
       IOC.Idling
         -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR  "No 'solve' without model" ]
               return Map.empty
       _ -> if  SortOf.sortOf vexp /= SortId.sortIdBool
                 then do
                   IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR
                                 "Value expression for solve shall be Bool" ]
                   return Map.empty
                 else do
                   let frees = FreeVar.freeVars vexp
                       assertions = Solve.add vexp Solve.empty
                   smtEnv        <- IOC.getSMT "current"
                   (sat,smtEnv') <- lift $ runStateT (Solve.solve frees assertions) smtEnv
                   IOC.putSMT "current" smtEnv'
                   case sat of
                     SolveDefs.Solved sol    -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "sat" ]
                                                   return sol
                     SolveDefs.Unsolvable    -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "unsat" ]
                                                   return Map.empty
                     SolveDefs.UnableToSolve -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "unknown" ]
                                                   return Map.empty


-- | Find an unique solution for the provided Boolean value expression.
--
--   Only possible when txscore is initialized.
txsUniSolve :: TxsDefs.VExpr            -- ^ value expression to solve uniquely.
            -> IOC.IOC (TxsDefs.WEnv VarId)
txsUniSolve vexp  =  do
     envc <- get
     case IOC.state envc of
       IOC.Idling
         -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "No 'solve' without model" ]
               return Map.empty
       _ -> if  SortOf.sortOf vexp /= SortId.sortIdBool
                 then do
                   IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Value expression shall be Bool" ]
                   return Map.empty
                 else do
                   let frees = FreeVar.freeVars vexp
                       assertions = Solve.add vexp Solve.empty
                   smtEnv        <- IOC.getSMT "current"
                   (sat,smtEnv') <- lift $ runStateT (Solve.uniSolve frees assertions) smtEnv
                   IOC.putSMT "current" smtEnv'
                   case sat of
                     SolveDefs.Solved sol    -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "sat" ]
                                                   return sol
                     SolveDefs.Unsolvable    -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "unsat" ]
                                                   return Map.empty
                     SolveDefs.UnableToSolve -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "unknown" ]
                                                   return Map.empty

-- | Find a random solution for the provided Boolean value expression.
--
--   Only possible when txscore is initialized.
txsRanSolve :: TxsDefs.VExpr                -- ^ value expression to solve randomly.
            -> IOC.IOC (TxsDefs.WEnv VarId)
txsRanSolve vexp  =  do
     envc <- get
     case IOC.state envc of
       IOC.Idling
         -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "No 'solve' without model" ]
               return Map.empty
       _ -> if  SortOf.sortOf vexp /= SortId.sortIdBool
                 then do
                   IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Value expression shall be Bool" ]
                   return Map.empty
                else do
                   let frees      = FreeVar.freeVars vexp
                       assertions = Solve.add vexp Solve.empty
                   smtEnv        <- IOC.getSMT "current"
                   parammap <- gets IOC.params
                   let p = Solve.toRandParam parammap
                   (sat,smtEnv') <- lift $ runStateT (Solve.randSolve p frees assertions) smtEnv
                   IOC.putSMT "current" smtEnv'
                   case sat of
                     SolveDefs.Solved sol    -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "sat" ]
                                                   return sol
                     SolveDefs.Unsolvable    -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "unsat" ]
                                                   return Map.empty
                     SolveDefs.UnableToSolve -> do IOC.putMsgs [ EnvData.TXS_CORE_RESPONSE
                                                                 "unknown" ]
                                                   return Map.empty

-}

-- ----------------------------------------------------------------------------------------- --

{-




-- | Start simulating.
--
--   Only possible when txscore is initialized.
txsSetSim :: (IOC.EWorld ew)
          => ew                                         -- ^ external world.
          -> TxsDefs.ModelDef                           -- ^ model definition.
          -> Maybe TxsDefs.MapperDef                    -- ^ optional mapper definition.
          -> IOC.IOC ew                                 -- ^ modified external world.
txsSetSim eWorld moddef mapdef  =  do
     envc <- get
     let cState = IOC.state envc
     case cState of
       IOC.Initing { IOC.smts = smts
                   , IOC.tdefs = tdefs
                   , IOC.sigs = sigs
                   , IOC.putmsgs = putmsgs
                   }
         -> do IOC.putCS IOC.Simuling { IOC.smts      = smts
                                      , IOC.tdefs     = tdefs
                                      , IOC.sigs      = sigs
                                      , IOC.modeldef  = moddef
                                      , IOC.mapperdef = mapdef
                                      , IOC.eworld    = eWorld
                                      , IOC.behtrie   = []
                                      , IOC.inistate  = 0
                                      , IOC.curstate  = 0
                                      , IOC.modsts    = []
                                      , IOC.mapsts    = []
                                      , IOC.putmsgs   = putmsgs
                                      }
               (maybt,mt) <- startSimulator moddef mapdef
               case maybt of
                 Nothing
                   -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Simulator start failed" ]
                         return eWorld
                 Just bt
                   -> do eWorld' <- IOC.startW eWorld
                         IOC.putCS IOC.Simuling { IOC.smts      = smts
                                                , IOC.tdefs     = tdefs
                                                , IOC.sigs      = sigs
                                                , IOC.modeldef  = moddef
                                                , IOC.mapperdef = mapdef
                                                , IOC.eworld    = eWorld'
                                                , IOC.behtrie   = []
                                                , IOC.inistate  = 0
                                                , IOC.curstate  = 0
                                                , IOC.modsts    = bt
                                                , IOC.mapsts    = mt
                                                , IOC.putmsgs   = putmsgs
                                                }
                         IOC.putMsgs [ EnvData.TXS_CORE_USER_INFO "Simulator started" ]
                         return eWorld'
       _ -> do                        -- IOC.noning, IOC.Testing, IOC.Simuling, IOC.Stepping --
               IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Simulator must start in Initing mode" ]
               return eWorld


startSimulator :: TxsDefs.ModelDef ->
                  Maybe TxsDefs.MapperDef ->
                  IOC.IOC ( Maybe BTree.BTree, BTree.BTree )

startSimulator (TxsDefs.ModelDef minsyncs moutsyncs msplsyncs mbexp)
               Nothing  =
     let allSyncs = minsyncs ++ moutsyncs ++ msplsyncs
     in do
       envb            <- filterEnvCtoEnvB
       (maybt', envb') <- lift $ runStateT (Behave.behInit allSyncs mbexp) envb
       writeEnvBtoEnvC envb'
       return ( maybt', [] )

startSimulator (TxsDefs.ModelDef minsyncs moutsyncs msplsyncs mbexp)
               (Just (TxsDefs.MapperDef achins achouts asyncsets abexp))  =
     let { mins  = Set.fromList minsyncs
         ; mouts = Set.fromList moutsyncs
         ; ains  = Set.fromList $ filter (not . Set.null)
                       [ sync `Set.intersection` Set.fromList achins  | sync <- asyncsets ]
         ; aouts = Set.fromList $ filter (not . Set.null)
                       [ sync `Set.intersection` Set.fromList achouts | sync <- asyncsets ]
         }
      in if     mouts `Set.isSubsetOf` ains
             && mins  `Set.isSubsetOf` aouts
           then do let allSyncs = minsyncs ++ moutsyncs ++ msplsyncs
                   envb            <- filterEnvCtoEnvB
                   (maybt',envb' ) <- lift $ runStateT (Behave.behInit allSyncs  mbexp) envb
                   (maymt',envb'') <- lift $ runStateT (Behave.behInit asyncsets abexp) envb'
                   writeEnvBtoEnvC envb''
                   case (maybt',maymt') of
                     (Nothing , _       ) -> do
                          IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester model failed" ]
                          return ( Nothing, [] )
                     (_       , Nothing ) -> do
                          IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Tester mapper failed" ]
                          return ( Nothing, [] )
                     (Just _, Just mt') ->
                          return ( maybt', mt' )
           else do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Inconsistent definitions" ]
                   return ( Nothing, [] )

-}

{-

-- | Test SUT with the provided input action.
-- core action.
--
-- Only possible in test modus (see 'txsSetTest').
-- Not possible with test purpose.
txsTestIn :: TxsDDefs.Action                    -- ^ input action to test SUT.
          -> IOC.IOC TxsDDefs.Verdict           -- ^ Verdict of test with provided input action.
txsTestIn act  =  do
     envc <- get
     case IOC.state envc of
       IOC.Testing { IOC.purpdef = Nothing }  -> do
         (_,verdict) <- Test.testIn act 1
         return verdict
       IOC.Testing {}                       -> do
         IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "No test action with test purpose" ]
         return TxsDDefs.NoVerdict
       _                                    -> do
         IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Not in Tester mode" ]
         return TxsDDefs.NoVerdict

-- | Test SUT by observing output action.
-- core action.
--
-- Only possible in test modus (see 'txsSetTest').
-- Not possible with test purpose.
txsTestOut :: IOC.IOC TxsDDefs.Verdict
txsTestOut  =  do
     envc <- get
     case IOC.state envc of
       IOC.Testing { IOC.purpdef = Nothing }    -> do
         (_, verdict) <- Test.testOut 1
         return verdict
       IOC.Testing {}                       -> do
         IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "No test output with test purpose" ]
         return TxsDDefs.NoVerdict
       _                                    -> do
         IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Not in Tester mode" ]
         return TxsDDefs.NoVerdict

-- | Test SUT with the provided number of actions.
-- core action.
--
-- Only possible in test modus (see 'txsSetTest').
txsTestN :: Int                         -- ^ number of actions to test SUT.
         -> IOC.IOC TxsDDefs.Verdict    -- ^ Verdict of test with provided number of actions.
txsTestN depth  =  do
     envc <- get
     case IOC.state envc of
      IOC.Testing { }-> Test.testN depth 1
      _ -> do
        IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Not in Tester mode" ]
        return TxsDDefs.NoVerdict

-- | Simulate model with the provided number of actions.
-- core action.
--
-- Only possible in simulation modus (see 'txsSetSim').
txsSimN :: Int                      -- ^ number of actions to simulate model.
        -> IOC.IOC TxsDDefs.Verdict -- ^ Verdict of simulation with number of actions.
txsSimN depth  =  do
     envc <- get
     case IOC.state envc of
       IOC.Simuling {} -> Sim.simN depth 1
       _ -> do
         IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Not in Simulator mode" ]
         return TxsDDefs.NoVerdict

-}

-- ----------------------------------------------------------------------------------------- --

{-

-- | Show provided item.
txsShow :: String               -- ^ kind of item to be shown.
        -> String               -- ^ name of item to be shown.
                                --   Valid items are "tdefs", "state",
                                --   "model", "mapper", "purp", "modeldef" \<name>,
                                --   "mapperdef" \<name>, "purpdef" \<name>
        -> IOC.IOC String
txsShow item nm  = do
     envc  <- gets IOC.state
     let tdefs = IOC.tdefs envc
     case envc of
      IOC.Idling{ }
         -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "Idling: nothing to be shown" ]
               return "\n"
      IOC.Initing{ }
         -> case (item,nm) of
              ("tdefs"    ,"") -> return $ show (IOC.tdefs envc)
              ("modeldef" ,_) -> return $ nm2string nm TxsDefs.IdModel TxsDefs.DefModel
                                                     (TxsDefs.modelDefs tdefs)
              ("mapperdef",_) -> return $ nm2string nm TxsDefs.IdMapper TxsDefs.DefMapper
                                                     (TxsDefs.mapperDefs tdefs)
              ("purpdef"  ,_) -> return $ nm2string nm TxsDefs.IdPurp TxsDefs.DefPurp
                                                     (TxsDefs.purpDefs tdefs)
              ("procdef"  ,_) -> return $ nm2string nm TxsDefs.IdProc TxsDefs.DefProc
                                                     (TxsDefs.procDefs tdefs)
              _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "nothing to be shown 1" ]
                      return "\n"
      _ -> case (item,nm) of
              ("tdefs"    ,"") -> return $ show (IOC.tdefs envc)
              ("state"    ,"") -> return $ show (IOC.curstate envc)
              ("model"    ,"") -> return $ TxsShow.fshow (IOC.modsts envc)
              ("mapper"   ,"") -> return $ TxsShow.fshow (IOC.mapsts envc)
              ("purp"     ,"") -> return $ TxsShow.fshow (IOC.purpsts envc)
              ("modeldef" ,_)  -> return $ nm2string nm TxsDefs.IdModel TxsDefs.DefModel
                                                     (TxsDefs.modelDefs tdefs)
              ("mapperdef",_)  -> return $ nm2string nm TxsDefs.IdMapper TxsDefs.DefMapper
                                                     (TxsDefs.mapperDefs tdefs)
              ("purpdef"  ,_)  -> return $ nm2string nm TxsDefs.IdPurp TxsDefs.DefPurp
                                                     (TxsDefs.purpDefs tdefs)
              ("procdef"  ,_)  -> return $ nm2string nm TxsDefs.IdProc TxsDefs.DefProc
                                                     (TxsDefs.procDefs tdefs)
              _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "nothing to be shown 2" ]
                      return "\n"

  where
     nm2string :: String
               -> (id -> TxsDefs.Ident)
               -> (def -> TxsDefs.TxsDef)
               -> Map.Map id def
               -> String
     nm2string nm' id2ident id2def iddefs =
       let defs = [ (id2ident id', id2def def) | (id', def) <- Map.toList iddefs
                                              , TxsDefs.name (id2ident id') == T.pack nm' ]
       in case defs of
            [(ident,txsdef)] -> TxsShow.fshow (ident,txsdef)
            _                -> "no (uniquely) defined item to be shown: " ++ nm' ++ "\n"

-}


{-

-- | Give the provided action to the mapper.
--
-- Not possible in stepper modus (see 'txsSetStep').
txsMapper :: TxsDDefs.Action                    -- ^ Action to be provided to mapper.
          -> IOC.IOC TxsDDefs.Action
txsMapper act  =  do
     envc <- get
     case IOC.state envc of
       IOC.Testing {} -> mapperMap act
       IOC.Simuling {} -> mapperMap act
       _ -> do
         IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR
                        "Mapping only allowed in Testing or Simulating mode" ]
         return act


-- | NComplete derivation by Petra van den Bos.
txsNComp :: TxsDefs.ModelDef                   -- ^ model. Currently only
                                               -- `StautDef` without data is
                                               -- supported.
         -> IOC.IOC (Maybe TxsDefs.PurpId)     -- ^ Derived purpose, when
                                               -- succesful.
txsNComp (TxsDefs.ModelDef insyncs outsyncs splsyncs bexp) =  do
  envc <- get
  case (IOC.state envc, TxsDefs.view bexp) of
    ( IOC.Initing {IOC.tdefs = tdefs}
      , TxsDefs.ProcInst procid@(TxsDefs.ProcId pnm _ _ _ _) chans []
      ) | and [ Set.size sync == 1 | sync <- insyncs ++ outsyncs ]
          && and [ null srts
                 | TxsDefs.ChanId _ _ srts <- Set.toList $ Set.unions $ insyncs ++ outsyncs
                 ]
          && null splsyncs
       -> case Map.lookup procid (TxsDefs.procDefs tdefs) of
              Just (TxsDefs.ProcDef chids [] staut@(TxsDefs.view -> TxsDefs.StAut _ ve _)) | Map.null ve
                 -> do let chanmap                       = Map.fromList (zip chids chans)
                           TxsDefs.StAut statid _ trans = TxsDefs.view $ Expand.relabel chanmap staut
                       maypurp <- NComp.nComplete insyncs outsyncs statid trans
                       case maypurp of
                         Just purpdef -> do
                           uid <- gets IOC.unid
                           let purpid = TxsDefs.PurpId ("PURP_"<>pnm) (uid+1)
                               tdefs' = tdefs
                                 { TxsDefs.purpDefs = Map.insert
                                                      purpid purpdef (TxsDefs.purpDefs tdefs)
                                 }
                           IOC.incUnid
                           IOC.modifyCS $ \st -> st { IOC.tdefs = tdefs' }
                           return $ Just purpid
                         _ -> return Nothing

              _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR
                                    "N-Complete requires a data-less STAUTDEF" ]
                      return Nothing
    _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR
                          $ "N-Complete should be used after initialization, before testing, "
                            ++ "with a STAUTDEF with data-less, singleton channels" ]
            return Nothing

-- ----------------------------------------------------------------------------------------- --

-- | LPE transformation by Carsten Ruetz
txsLPE :: Either TxsDefs.BExpr TxsDefs.ModelId   -- ^ either a behaviour expression (that shall
                                                 --   be a process instantiation), or a model
                                                 --   definition (that shall contain a process
                                                 --   instantiation), to be tranformed
       -> IOC.IOC (Maybe (Either TxsDefs.BExpr TxsDefs.ModelId))
                                                 -- ^ transformed process instantiation
                                                 --   or model definition

txsLPE (Left bexpr)  =  do
  envc <- get
  case IOC.state envc of
    IOC.Initing {IOC.tdefs = tdefs}
      -> do lpe <- LPE.lpeTransform bexpr (TxsDefs.procDefs tdefs)
            case lpe of
              Just (procinst'@(TxsDefs.view -> TxsDefs.ProcInst procid' _ _), procdef')
                -> case Map.lookup procid' (TxsDefs.procDefs tdefs) of
                     Nothing
                       -> do let tdefs' = tdefs { TxsDefs.procDefs = Map.insert
                                                    procid' procdef' (TxsDefs.procDefs tdefs)
                                                }
                             IOC.modifyCS $ \st -> st { IOC.tdefs = tdefs' }
                             return $ Just (Left procinst')
                     _ -> do IOC.putMsgs [ EnvData.TXS_CORE_SYSTEM_ERROR
                                           "LPE: generated process id already exists" ]
                             return Nothing
              _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "LPE: transformation failed" ]
                      return Nothing
    _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "LPE: only allowed if initialized" ]
            return Nothing

txsLPE (Right modelid@(TxsDefs.ModelId modname _moduid))  =  do
  envc <- get
  case IOC.state envc of
    IOC.Initing {IOC.tdefs = tdefs}
      -> case Map.lookup modelid (TxsDefs.modelDefs tdefs) of
           Just (TxsDefs.ModelDef insyncs outsyncs splsyncs bexpr)
             -> do lpe' <- txsLPE (Left bexpr)
                   lift $ hPrint stderr lpe'
                   case lpe' of
                     Just (Left (procinst'@(TxsDefs.view -> TxsDefs.ProcInst{})))
                       -> do uid'   <- IOC.newUnid
                             tdefs' <- gets (IOC.tdefs . IOC.state)
                             let modelid' = TxsDefs.ModelId ("LPE_"<>modname) uid'
                                 modeldef'= TxsDefs.ModelDef insyncs outsyncs splsyncs procinst'
                                 tdefs''  = tdefs'
                                   { TxsDefs.modelDefs = Map.insert modelid' modeldef'
                                                                    (TxsDefs.modelDefs tdefs')
                                   }
                             IOC.modifyCS $ \st -> st { IOC.tdefs = tdefs'' }
                             return $ Just (Right modelid')
                     _ -> do IOC.putMsgs [ EnvData.TXS_CORE_SYSTEM_ERROR $ "LPE: " ++
                                           "transformation on behaviour of modeldef failed" ]
                             return Nothing
           _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "LPE: model not defined" ]
                   return Nothing
    _ -> do IOC.putMsgs [ EnvData.TXS_CORE_USER_ERROR "LPE: only allowed if initialized" ]
            return Nothing

-}

-- ----------------------------------------------------------------------------------------- --
--                                                                                           --
-- ----------------------------------------------------------------------------------------- --
