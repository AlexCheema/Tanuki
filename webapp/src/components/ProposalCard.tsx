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
  const handleVote = (vote: "yes" | "no") => {
    onVote(proposal.id, vote);
  };

  return (
    
    <div className="bg-white rounded-lg shadow-lg p-6 mb-4 border-2 border-gradient">
      <h3 className="text-xl font-bold mb-2">{proposal.title}</h3>
      <p className="text-gray-800 mb-4">{proposal.description}</p>
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
