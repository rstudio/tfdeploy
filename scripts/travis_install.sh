pip2.7 install --upgrade --ignore-installed --user travis pip setuptools wheel virtualenv

if [[ "$TF_VERSION" == "1.3" ]]; then
      echo "Installing TensorFlow v1.3 ...";
      Rscript -e 'tensorflow::install_tensorflow(version = "1.3")';
elif [[ "$TF_VERSION" == "1.4" ]]; then
      echo "Installing TensorFlow v1.4 ...";
      Rscript -e 'tensorflow::install_tensorflow(version = "1.4")';
elif [[ "$TF_VERSION" == "1.7" ]]; then
      echo "Installing TensorFlow v1.7 ...";
      Rscript -e 'tensorflow::install_tensorflow(version = "1.7")';
elif [[ "$TF_VERSION" == "nightly" ]]; then
      echo "Installing TensorFlow nightly ...";
      Rscript -e 'tensorflow::install_tensorflow(version = "nightly")';
else
      echo "Installing Tensorflow $TF_VERSION ..."
      Rscript -e 'tensorflow::install_tensorflow(version = "${TF_VERSION}")';
fi
