import {Strings} from "./lib/@openzeppelin/contracts/utils/Strings.sol";
import {Prover} from "vlayer-0.1.0/src/Prover.sol";
import {VerifiedEmail, UnverifiedEmail, EmailProofLib} from "vlayer-0.1.0/src/EmailProof.sol";
import {EmailStrings} from "./EmailStrings.sol";

contract BoltTripEmailProver is Prover {
  using Strings for string;
  using EmailStrings for string;
  using EmailProofLib for UnverifiedEmail;

  string targetDomain = "bangkok@bolt.eu";

  constructor() { }

  function proof(UnverifiedEmail calldata unverifiedEmail,
    string memory date, string memory pickupTime, string memory dropoffTime, address targetWallet
  ) public view returns (Proof, bytes32, address)
  {
    VerifiedEmail memory email = unverifiedEmail.verify();

    require(email.from.equal(targetDomain), "incorrect sender domain");
    require(email.subject.contains("Verify me for company NFT"), "incorrect subject");

    return (proof(), sha256(abi.encodePacked(email.from)), targetWallet);
  }
}
