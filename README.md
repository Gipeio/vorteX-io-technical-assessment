## Aditionnal installations

### tests:

pip install pytest-cov

## Remarks

in the test file, the "sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))" line is there because of an anomaly where pytest doesnt look in the right modules, might be caused by Dev Container
