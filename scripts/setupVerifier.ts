import { HardhatRuntimeEnvironment } from "hardhat/types";
import dotenv from "dotenv"
import {mainWallet, makeContract, sendTx, setupHRE} from "../utils/contract";
import hre from "hardhat";
import {parseEther} from "ethers/lib/utils";

dotenv.config();

export async function main(hre: HardhatRuntimeEnvironment) {
  setupHRE(hre);

  const verifierAddress = "0x6e18cef18cbf6ceb96a52ab71f5330c4f312cf47";

  const [platform] = await makeContract("BOTPlatform");

  await sendTx(platform.changeVerifier(verifierAddress), "changeVerifier");
}

main(hre).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
