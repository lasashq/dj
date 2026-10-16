{ lib, buildPythonPackage, fetchPypi, fetchurl, linkFarm, setuptools
, numpy, librosa, soundfile, onnxruntime, filelock, tqdm }:

# DPDFNet speech enhancement (https://github.com/ceva-ip/DPDFNet).
# Models are fetched at build time (passthru.models); point DPDFNET_MODEL_DIR
# at them so nothing is downloaded at runtime.
let
  # Hugging Face revision of Ceva-IP/DPDFNet the hashes below belong to.
  modelsRev = "dd6818d00f50c836fed43a6243ebe49116de5964";
  modelHashes = {
    baseline = "sha256-Nx0mGCr/Dh4NMTVOJMgfec1XRY9afdAD/BCn6/ZCVeA=";
    dpdfnet2 = "sha256-Tw7iiTW0oyq+zHF9dFQWl2Vlg02DlgGs9DAxCUtNyUw=";
    dpdfnet4 = "sha256-QqOG02AZIvR0xDCZJ+H0cczkIum9jj/Tlnu5Q7rDbAE=";
    dpdfnet8 = "sha256-iZ1PI/P/hu2/+oxTfkvL3EnaG06E4O85BhHgYEo7Jss=";
    dpdfnet2_8khz = "sha256-Yhjx29bkusV2jGO32Jn+e4SzeI8qNcTiRtSrCUYWXF0=";
    dpdfnet8_8khz = "sha256-wGG8xWuAP6L6l9RIpF222Wb30Xr/EwTkZEVddIdF6mI=";
    dpdfnet2_48khz_hr = "sha256-fwV1pc7Auk/9j4vWV+BtAH5MzdlV12+quSK50ykdwUs=";
    dpdfnet8_48khz_hr = "sha256-ezr7smCgj+mvPRbjvamSlxvh5+lR0d7nwtI19cQ/VjE=";
  };

  models = linkFarm "dpdfnet-models" (lib.mapAttrsToList (name: hash: {
    name = "${name}.onnx";
    path = fetchurl {
      url = "https://huggingface.co/Ceva-IP/DPDFNet/resolve/${modelsRev}/onnx/${name}.onnx";
      inherit hash;
    };
  }) modelHashes);
in
buildPythonPackage rec {
  pname = "dpdfnet";
  version = "0.6.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QPST8SARa67NnHZWod3BtD7hCwcLJHUlyZ2dbA99W+8=";
  };

  build-system = [ setuptools ];

  dependencies = [ numpy librosa soundfile onnxruntime filelock tqdm ];

  pythonImportsCheck = [ "dpdfnet" ];

  passthru = { inherit models; };

  meta = {
    description = "CPU-only ONNX inference for DPDFNet speech enhancement";
    homepage = "https://github.com/ceva-ip/DPDFNet";
    license = lib.licenses.asl20;
  };
}
