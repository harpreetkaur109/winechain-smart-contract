//import { ethers ,waffle} from "hardhat";

import { Console } from "console";

const SIGNING_DOMAIN_NAME = "WineChain_NFT_Voucher"; // encode krne ke liye salt lgti hai  ex:-  adding formula  values alg dono ki 2 persons
const SIGNING_DOMAIN_VERSION = "1";

/**
 *
 * LazyMinting is a helper class that creates NFTVoucher objects and signs them, to be redeemed later by the LazyNFT contract.
 */
class SellerVoucher {
  public contract: any;
  public signer: any;
  public _domain: any;
  public voucherCount: number = 0;
  public signer2: any;

  constructor(data: any) {
    const { _contract, _signer } = data;
    this.contract = _contract;
    this.signer = _signer;
  }

  async createVoucher(
    winery: any,
    seller: any,
    tokenId: any,
    price: any,
  ) {
    const voucher = {
        winery,
        seller,
        tokenId,
        price,
    };
    const domain = await this._signingDomain();
    const types = {
      NFTSell: [
        { name: "winery", type: "address" },
        { name: "seller", type: "address" },
        { name: "tokenId", type: "uint256" },
        { name: "price", type: "uint256" },
      ],
    };
    // console.log("let me know",voucher);
    // console.log("let me domain",domain);
    // console.log("let me signer",this.signer.address);

    const signature = await this.signer._signTypedData(domain, types, voucher);
    console.log("signature",signature);
    console.log(voucher,"voucher");
    return {
      ...voucher,
      signature,
    };
  }

  async _signingDomain() {
    if (this._domain != null) {
      return this._domain;
    }
    // console.log("chain ID");
    const chainId = await this.contract.getChainID();//chain id error
    
    this._domain = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      verifyingContract: this.contract.address,
      chainId,
    };
    return this._domain;
  }
}

export default SellerVoucher;
