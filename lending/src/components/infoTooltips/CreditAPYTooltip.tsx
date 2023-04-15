import { Trans } from '@lingui/macro';

import { TextWithTooltip, TextWithTooltipProps } from '../TextWithTooltip';

export const CreditAPYTooltip = ({ ...rest }: TextWithTooltipProps) => {
  return (
    <TextWithTooltip {...rest}>
      <Trans>
        Credit score interest rate is calculated using your <b>on-chain credit score</b>. Connect a wallet address
        to view your personalized interest rate.
      </Trans>
    </TextWithTooltip>
  );
};
