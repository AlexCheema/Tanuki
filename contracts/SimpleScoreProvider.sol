pragma solidity >=0.8.0 <0.9.0;

import "./IScoreProvider.sol";

contract SimpleScoreProvider is IScoreProvider {
    function viewScore(address account) external view override returns (uint256) {
        return 1;
    }
}
