<<<<<<< HEAD
pragma solidity ^0.8.9;
=======
pragma solidity ^0.8.12;
>>>>>>> 75719bc (implement deployment of SimpleScorePRovider and gov contracts)

import "./IScoreProvider.sol";

contract SimpleScoreProvider is IScoreProvider {
<<<<<<< HEAD
    function viewScore(address account) external view override returns (uint256) {
        return uint256(uint160(xAddr)) % 100;
    }
}
=======
    function viewScore(address xAddr) external pure override returns (uint256) {
        return uint256(uint160(xAddr)) % 100;
    }
}
>>>>>>> 75719bc (implement deployment of SimpleScorePRovider and gov contracts)
