import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {getContract, mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const token = await getContract("TestToken")
  const platform = await getContract("BOTPlatform");

  await sendTx(token.transfer(platform.address, parseEther("10000")), "transfer");
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
