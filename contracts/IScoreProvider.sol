pragma solidity ^0.8.0;

interface IScoreProvider {
    function viewScore(address account) external view returns (uint256);
    function updateScores(uint256 startBlock, uint256 endBlock, bytes calldata zkProof) external;
}

