pragma solidity ^0.8.0;

import "./IAxiomV0.sol";
import "./IScoreProvider.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AxiomActivityScoreProvider is Ownable, IScoreProvider {
    uint256 public constant VERSION = 0;

    // The public inputs and outputs of the ZK proof
    struct Instance {
        address poolAddress;
        uint32 startBlockNumber;
        uint32 endBlockNumber;
        bytes32 startBlockHash;
        bytes32 endBlockHash;
        Observation startObservation;
        Observation endObservation;
    }

    address private axiomAddress;
    address private verifierAddress;

    // @notice Mapping between user contract address and their score
    mapping(address => uint256) public scores;

    event UpdateAxiomAddress(address newAddress);
    event UpdateSnarkVerifierAddress(address newAddress);

    constructor(address _axiomAddress, address _verifierAddress) {
        axiomAddress = _axiomAddress;
        verifierAddress = _verifierAddress;
    }

    function updateAxiomAddress(address _axiomAddress) external onlyOwner {
        axiomAddress = _axiomAddress;
        emit UpdateAxiomAddress(_axiomAddress);
    }

    function updateSnarkVerifierAddress(address _verifierAddress) external onlyOwner {
        verifierAddress = _verifierAddress;
        emit UpdateSnarkVerifierAddress(_verifierAddress);
    }

    function viewScore(address account) external view override returns (uint256) {
        return scores[account];
    }

    struct Observation {
        // the block timestamp of the observation
        uint32 blockTimestamp;
        // the tick accumulator, i.e. tick * time elapsed since the pool was first initialized
        int56 tickCumulative;
        // the seconds per liquidity, i.e. seconds elapsed / max(1, liquidity) since the pool was first initialized
        uint160 secondsPerLiquidityCumulativeX128;
        // whether or not the observation is initialized
        bool initialized;
    }

    function unpackScoreMapping(uint256 scoreMapping) internal pure returns (Oracle.ScoreMapping memory) {
        // TODO: change this to unpack a mapping from address to score
        // observation` (31 bytes) is single field element, concatenation of `secondsPerLiquidityCumulativeX128 . tickCumulative . blockTimestamp`
        return Observation({
            blockTimestamp: uint32(observation),
            tickCumulative: int56(uint56(observation >> 32)),
            // TODO: replace secondsPerLiquidityCumulativeX128
            secondsPerLiquidityCumulativeX128: uint160(observation >> 88),
            initialized: true
        });
    }

    function getProofInstance(bytes calldata proof)
        internal
        pure
        returns (Instance memory instance, bytes32 startObservationPacked, bytes32 endObservationPacked)
    {
        // Public instances: total 7 field elements
        // 0: `pool_address . start_block_number . end_block_number` is `20 + 4 + 4 = 28` bytes, packed into a single field element
        // 1..3: `start_block_hash` (32 bytes) is split into two field elements (hi, lo u128)
        // 3..5: `end_block_hash` (32 bytes) is split into two field elements (hi, lo u128)
        // 5: `score_mapping` (31 bytes) is a mapping from address to score.
        bytes32[7] memory fieldElements;
        // The first 4 * 3 * 32 bytes give two elliptic curve points for internal pairing check
        uint256 start = 384;
        for (uint256 i = 0; i < 7; i++) {
            fieldElements[i] = bytes32(proof[start:start + 32]);
            start += 32;
        }
        instance.serviceAddress = address(bytes20(fieldElements[0] << 32)); // 4 * 8, bytes is right padded so conversion is from left
        instance.startBlockNumber = uint32(bytes4(fieldElements[0] << 192)); // 24 * 8
        instance.endBlockNumber = uint32(bytes4(fieldElements[0] << 224)); // 28 * 8
        instance.startBlockHash = bytes32((uint256(fieldElements[1]) << 128) | uint128(uint256(fieldElements[2])));
        instance.endBlockHash = bytes32((uint256(fieldElements[3]) << 128) | uint128(uint256(fieldElements[4])));
        instance.startObservation = unpackScoreMapping(uint256(fieldElements[5]));
        instance.endObservation = unpackScoreMapping(uint256(fieldElements[6]));
    }

    function validateBlockHash(IAxiomV0.BlockHashWitness calldata witness) internal view {
        if (block.number - witness.blockNumber <= 256) {
            if (!IAxiomV0(axiomAddress).isRecentBlockHashValid(witness.blockNumber, witness.claimedBlockHash)) {
                revert("BlockHashWitness is not validated by Axiom");
            }
        } else {
            if (!IAxiomV0(axiomAddress).isBlockHashValid(witness)) {
                revert("BlockHashWitness is not validated by Axiom");
            }
        }
    }

    function updateScores(
        IAxiomV0.BlockHashWitness calldata startBlock,
        IAxiomV0.BlockHashWitness calldata endBlock,
        bytes calldata proof
    ) external override {
        (Instance memory instance, bytes32 startObservationPacked, bytes32 endObservationPacked) =
            getProofInstance(proof);
        // compare calldata vs proof instances:
        if (instance.startBlockNumber > instance.endBlockNumber) {
            revert("startBlockNumber <= endBlockNumber");
        }
        if (instance.startBlockNumber != startBlock.blockNumber) {
            revert("instance.startBlockNumber != startBlock.blockNumber");
        }
        if (instance.endBlockNumber != endBlock.blockNumber) {
            revert("instance.endBlockNumber != endBlock.blockNumber");
        }
        if (instance.startBlockHash != startBlock.claimedBlockHash) {
            revert("instance.startBlockHash != startBlock.claimedBlockHash");
        }
        if (instance.endBlockHash != endBlock.claimedBlockHash) {
            revert("instance.endBlockHash != endBlock.claimedBlockHash");
        }
        // Use Axiom to validate block hashes
        validateBlockHash(startBlock);
        validateBlockHash(endBlock);

        (bool success,) = verifierAddress.call(proof);
        if (!success) {
            revert("Proof verification failed");
        }
        
        scoreMappings = instance.endObservation;
    }
}
