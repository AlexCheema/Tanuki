import { useContract, useSigner } from "wagmi";
import { GovernorABI } from "../pages/index";
import { BigNumber } from "ethers";

export type Proposal = {
  id: string;
  title: string;
  description: string;
  yesVotes: bigint;
  noVotes: bigint;
}

interface IProposalCard {
  proposal: Proposal;
  onVote: (proposalId: string, vote: "yes" | "no") => void;
}

const ProposalCard = ({ proposal, onVote }: IProposalCard) => {
  const signer = useSigner();
  const Contract = useContract({
    abi: GovernorABI,
    address: "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9",
    signerOrProvider: signer.data,
  })

  const handleVote = (vote: "yes" | "no") => {
    onVote(proposal.id, vote);
    Contract?.castVote(BigNumber.from(proposal.id), vote === "yes" ? 1 : 0);
  };

  return (
    
    <div className="bg-white rounded-lg shadow-lg p-6 mb-4 border-2 border-gradient">
      <h3 className="text-xl font-bold mb-2">{proposal.title}</h3>
      <div className="flex justify-between items-center">
        <div className="flex items-center">
          <button
            className="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"
            onClick={() => handleVote("yes")}
          >
            Yes
          </button>
          <button
            className="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded ml-4"
            onClick={() => handleVote("no")}
          >
            No
          </button>
        </div>
        <p className="text-gray-700 font-bold">
          {proposal.yesVotes} Yes / {proposal.noVotes} No
        </p>
      </div>
    </div>
  );
};

export default ProposalCard;
