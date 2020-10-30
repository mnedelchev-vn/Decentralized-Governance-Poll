<snippet>
  <content><![CDATA[
# ${1:Governance-Decentralized-Poll}
Governance decentralized poll which is built to work with any kind of ERC20 token.
## Purpose
This contract brings the decentralization for any kind of ERC20 token. The purpose of the contract is to allow users which are holders of the particular ERC20 token to take part in the decision making of the currency. The contract is built in such cost efficient way that user doesn't have to transfer ( lock ) his ERC20 tokens to the contract, but instead he have to only hold them until the poll finish date.
## Roles
* Poll creator
* Poll voters
## Features
1. Compatible with any ERC20 token.
2. Once poll is created, the poll owner cannot vote.
3. Each poll voter can vote only once.
4. The poll creator have the option to setup maximum count of poll voter to vote.
5. The poll creator have the option to setup minimum and/ or maximum token amount owned by the poll voter in order to allow him to vote.
6. The voter have the option to decide by him self with what token amount he want to place his vote. The voting method is checking if the voter really holds the token amount. However the tokens are not leaving votes address.
7. The poll creator have the option to setup start and finish date of the poll.
8. The poll creator have the option to setup as many poll options as needed. ( poll options are stored in array of base32 format, this leads to a limitation in the length of the string ). In order to display the base32 poll options into readable strings you can use `web3.utils.toAscii()` on the front-end side.
9. Contract method `getPollVotes()` provides the option to take a snapshot of the current poll results. Setting parameter `_tokenAmountCheck` to `true` will make the method to check if the voter still have the token amount which he claimed to have during the time of his vote. This check prevents from users voting with same token amount from multiple addresses.
]]></content>
  <tabTrigger>readme</tabTrigger>
</snippet>