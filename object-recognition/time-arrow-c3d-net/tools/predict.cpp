#include <stdio.h>  // for snprintf
// #include <cuda_runtime.h>

#include <fstream>  // NOLINT(readability/streams)
#include <iostream>  // NOLINT(readability/streams)
#include <string>
#include <vector>

#include "caffe/blob.hpp"
#include "caffe/common.hpp"
#include "caffe/net.hpp"
#include "caffe/proto/caffe.pb.h"
#include "caffe/util/image_io.hpp"
#include "caffe/util/io.hpp"
#include "google/protobuf/text_format.h"

using namespace caffe;  // NOLINT(build/namespaces)

template<typename Dtype>
int feature_extraction_pipeline(int argc, char** argv);

int main(int argc, char** argv) {
  return feature_extraction_pipeline<float>(argc, argv);
}

template<typename Dtype>
int feature_extraction_pipeline(int argc, char** argv) {
  char* net_proto = argv[1];
  char* pretrained_model = argv[2];
  int device_id = atoi(argv[3]);
  uint batch_size = atoi(argv[4]);
  uint num_mini_batches = atoi(argv[5]);
  char* fn_feat = argv[6];

  // Caffe::set_phase(Caffe::TEST);
  if (device_id >= 0) {
      Caffe::set_mode(Caffe::GPU);
      Caffe::SetDevice(device_id);
      LOG(ERROR) << "Using GPU #" << device_id;
  } else {
      Caffe::set_mode(Caffe::CPU);
      LOG(ERROR) << "Using CPU";
  }

  shared_ptr<Net<Dtype> > feature_extraction_net(
      new Net<Dtype>(string(net_proto), caffe::TEST));
  feature_extraction_net->CopyTrainedLayersFrom(string(pretrained_model));

  for (int i = 7; i < argc; i++) {
  CHECK(feature_extraction_net->has_blob(string(argv[i])))
      << "Unknown feature blob name " << string(argv[i])
      << " in the network " << string(net_proto);
  }

  LOG(ERROR)<< "Extracting features for " << num_mini_batches << " batches";
  std::ifstream infile(fn_feat);
  string feat_prefix;
  std::vector<string> list_prefix;
  // int c = 0;

  vector<Blob<float>*> input_vec;
  int image_index = 0;

  for (int batch_index = 0; batch_index < num_mini_batches; ++batch_index) {
    feature_extraction_net->Forward(input_vec);
    list_prefix.clear();
    for (int n = 0; n < batch_size; n++) {
        if (infile >> feat_prefix)
            list_prefix.push_back(feat_prefix);
        else
            break;
    }

    if (list_prefix.empty())
        break;
    for (int k = 7; k < argc; k++) {
        const shared_ptr<Blob<Dtype> > feature_blob = feature_extraction_net
        ->blob_by_name(string(argv[k]));
        int num_features = feature_blob->num();

        // Dtype* feature_blob_data;
        for (int n = 0; n < num_features; ++n) {
          if (list_prefix.size() > n) {
              string fn_feat = list_prefix[n] + string(".") + string(argv[k]);
              save_blob_to_binary(feature_blob.get(), fn_feat, n);
          }
        }
    }
    image_index += list_prefix.size();
    if (batch_index % 100 == 0) {
        LOG(ERROR)<< "Extracted features of " << image_index <<
            " images.";
    }
  }
  LOG(ERROR)<< "Successfully extracted " << image_index << " features!";
  infile.close();
  return 0;
}

