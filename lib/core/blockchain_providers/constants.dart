import '../models/chain_metadata.dart';

const String WEB3_AUTH_PRIV_KEY = "WEB3_AUTH_PRIV_KEY";
const String WEB3_AUTH_EMAIL_KEY = "WEB3_AUTH_EMAIL_KEY";
const String WEB3_AUTH_NAME_KEY = "WEB3_AUTH_NAME_KEY";
const String WEB3_AUTH_PROFILE_KEY = "WEB3_AUTH_PROFILE_KEY";

const String WC_AUTH_PUB_KEY = "WC_AUTH_PUB_KEY";
const String WC_ACCOUNT = "WC_ACCOUNT";
const String WC_AUTH_SESSION_TOPIC = "WC_AUTH_SESSION_TOPIC";

const String INTERNAL_AUTH_PRIV_KEY = "INTERNAL_AUTH_PRIV_KEY";

const CHAINS = [
  // ChainMetadata(
  //   chainId: 'eip155:1',
  //   name: 'Ethereum',
  //   logo: '/chain-logos/eip155-1.png',
  //   rpc: ['https://cloudflare-eth.com/'],
  // ),
  // ChainMetadata(
  //   chainId: 'eip155:137',
  //   name: 'Polygon',
  //   logo: '/chain-logos/eip155-137.png',
  //   rpc: ['https://polygon-rpc.com/'],
  // ),
  ChainMetadata(
    chainId: 'eip155:80001',
    name: 'Polygon Mumbai',
    logo: '/chain-logos/eip155-137.png',
    isTestnet: true,
    rpc: ['https://matic-mumbai.chainstacklabs.com'],
  )
];
