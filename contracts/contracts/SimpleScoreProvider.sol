pragma solidity ^0.8.9;

import "./IScoreProvider.sol";

contract SimpleScoreProvider is IScoreProvider {
    function viewScore(address account) external view override returns (uint256) {
        return uint256(uint160(xAddr)) % 100;
    }
}
