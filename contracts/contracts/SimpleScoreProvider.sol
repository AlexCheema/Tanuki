pragma solidity ^0.8.12;

import "./IScoreProvider.sol";

contract SimpleScoreProvider is IScoreProvider {
    function viewScore(address xAddr) external pure override returns (uint256) {
        return uint256(uint160(xAddr)) % 100;
    }
}
