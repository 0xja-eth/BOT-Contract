import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";

dotenv.config();

export async function deploy(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const [factory] = await makeContract("LazyBetFactory");
}

deploy(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
