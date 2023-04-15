pragma solidity ^0.8.0;

interface IScoreProvider {
    function viewScore(address account) external view returns (uint256);
}

