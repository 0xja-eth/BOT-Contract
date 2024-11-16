import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const verifierAddress = "";

  const [platform] = await makeContract("BOTPlatform");

  await sendTx(platform.changeVerifier(verifierAddress), "changeVerifier");
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
