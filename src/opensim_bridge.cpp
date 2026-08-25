#include <algorithm>
#include <cctype>
#include <fstream>
#include <memory>
#include <string>
#include <vector>

#ifdef PHYSIO_OPENSIM_ENABLED
#ifdef CHAR
#undef CHAR
#endif
#include <OpenSim/OpenSim.h>
#endif

#include <Rcpp.h>

#ifndef PHYSIO_OPENSIM_DETECT_METHOD
#define PHYSIO_OPENSIM_DETECT_METHOD unknown
#endif

#define PHYSIO_OPENSIM_STRINGIFY_INNER(x) #x
#define PHYSIO_OPENSIM_STRINGIFY(x) PHYSIO_OPENSIM_STRINGIFY_INNER(x)

namespace {

void assert_file_readable(const std::string& path, const std::string& label) {
  std::ifstream fin(path.c_str());
  if (!fin.good()) {
    Rcpp::stop(label + " does not exist or is not readable: " + path);
  }
}

#ifdef PHYSIO_OPENSIM_ENABLED

struct ModelHandle {
  explicit ModelHandle(const std::string& path)
      : model(new OpenSim::Model(path)), state(nullptr), initialized(false) {}

  std::unique_ptr<OpenSim::Model> model;
  std::unique_ptr<SimTK::State> state;
  bool initialized;
};

ModelHandle& handle_from_xptr(SEXP model_ptr) {
  if (TYPEOF(model_ptr) != EXTPTRSXP || R_ExternalPtrAddr(model_ptr) == nullptr) {
    Rcpp::stop("`model` must be a valid PhysioOpenSim model external pointer.");
  }

  Rcpp::XPtr<ModelHandle> xptr(model_ptr);
  if (!xptr || !xptr->model) {
    Rcpp::stop("OpenSim model handle is null.");
  }
  return *xptr;
}

void initialize_state(ModelHandle& handle) {
  SimTK::State& state_ref = handle.model->initSystem();
  handle.state.reset(new SimTK::State(state_ref));
  handle.initialized = true;
}

template <typename TSet>
Rcpp::CharacterVector names_from_set(const TSet& x) {
  const int n = x.getSize();
  Rcpp::CharacterVector out(n);
  for (int i = 0; i < n; ++i) {
    out[i] = x.get(i).getName();
  }
  return out;
}

Rcpp::List model_summary_from_handle(ModelHandle& handle) {
  if (!handle.initialized || !handle.state) {
    initialize_state(handle);
  }

  return Rcpp::List::create(
      Rcpp::Named("model_name") = handle.model->getName(),
      Rcpp::Named("n_bodies") = handle.model->getBodySet().getSize(),
      Rcpp::Named("n_joints") = handle.model->getJointSet().getSize(),
      Rcpp::Named("n_markers") = handle.model->getMarkerSet().getSize(),
      Rcpp::Named("n_muscles") = handle.model->getMuscles().getSize(),
      Rcpp::Named("n_coordinates") = handle.model->getCoordinateSet().getSize(),
      Rcpp::Named("total_mass") = handle.model->getTotalMass(*handle.state),
      Rcpp::Named("initialized") = handle.initialized);
}

std::string to_lower(std::string x) {
  std::transform(x.begin(), x.end(), x.begin(), [](unsigned char c) {
    return static_cast<char>(std::tolower(c));
  });
  return x;
}

#endif

}  // namespace

// [[Rcpp::export]]
bool cpp_opensim_compiled() {
#ifdef PHYSIO_OPENSIM_ENABLED
  return true;
#else
  return false;
#endif
}

// [[Rcpp::export]]
Rcpp::List cpp_opensim_build_config() {
  return Rcpp::List::create(
      Rcpp::Named("opensim_enabled") = cpp_opensim_compiled(),
      Rcpp::Named("detect_method") =
          std::string(PHYSIO_OPENSIM_STRINGIFY(PHYSIO_OPENSIM_DETECT_METHOD)));
}

// Native OpenSim / Simbody version strings, or empty when built without OpenSim.
// [[Rcpp::export]]
Rcpp::List cpp_opensim_version() {
  std::string opensim_ver;
  std::string simbody_ver;
#ifdef PHYSIO_OPENSIM_ENABLED
  opensim_ver = OpenSim::GetVersion();
#ifdef SimTK_SIMBODY_VERSION_STRING
  simbody_ver = SimTK_SIMBODY_VERSION_STRING;
#endif
#endif
  return Rcpp::List::create(
      Rcpp::Named("opensim") = opensim_ver,
      Rcpp::Named("simbody") = simbody_ver);
}

// [[Rcpp::export]]
Rcpp::List cpp_opensim_model_summary(const std::string& path) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop(
      "PhysioOpenSim was compiled without OpenSim support. "
      "Set PKG_CONFIG_PATH for OpenSim pkg-config or OPENSIM_HOME before install.");
#else
  assert_file_readable(path, "Model file");
  ModelHandle handle(path);
  return model_summary_from_handle(handle);
#endif
}

// [[Rcpp::export]]
SEXP cpp_opensim_model_load(const std::string& path) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop(
      "PhysioOpenSim was compiled without OpenSim support. "
      "Reinstall with OpenSim development libraries available.");
#else
  assert_file_readable(path, "Model file");
  Rcpp::XPtr<ModelHandle> ptr(new ModelHandle(path), true);
  return ptr;
#endif
}

// [[Rcpp::export]]
bool cpp_opensim_model_is_initialized(SEXP model_ptr) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  return handle.initialized;
#endif
}

// [[Rcpp::export]]
bool cpp_opensim_model_init(SEXP model_ptr) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  initialize_state(handle);
  return true;
#endif
}

// [[Rcpp::export]]
Rcpp::List cpp_opensim_model_summary_ptr(SEXP model_ptr) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  return model_summary_from_handle(handle);
#endif
}

// [[Rcpp::export]]
Rcpp::List cpp_opensim_model_components(SEXP model_ptr) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  return Rcpp::List::create(
      Rcpp::Named("body_names") = names_from_set(handle.model->getBodySet()),
      Rcpp::Named("joint_names") = names_from_set(handle.model->getJointSet()),
      Rcpp::Named("marker_names") = names_from_set(handle.model->getMarkerSet()),
      Rcpp::Named("muscle_names") = names_from_set(handle.model->getMuscles()),
      Rcpp::Named("coordinate_names") =
          names_from_set(handle.model->getCoordinateSet()));
#endif
}

// [[Rcpp::export]]
std::string cpp_opensim_model_get_name(SEXP model_ptr) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  return handle.model->getName();
#endif
}

// [[Rcpp::export]]
void cpp_opensim_model_set_name(SEXP model_ptr, const std::string& name) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  handle.model->setName(name);
#endif
}

// [[Rcpp::export]]
void cpp_opensim_model_finalize_connections(SEXP model_ptr) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  handle.model->finalizeConnections();
#endif
}

// [[Rcpp::export]]
void cpp_opensim_model_save(SEXP model_ptr, const std::string& output_file) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop("OpenSim support is not available in this build.");
#else
  ModelHandle& handle = handle_from_xptr(model_ptr);
  handle.model->print(output_file);
#endif
}

// [[Rcpp::export]]
Rcpp::List cpp_opensim_run_tool_native(const std::string& setup_file,
                                       const std::string& tool) {
#ifndef PHYSIO_OPENSIM_ENABLED
  Rcpp::stop(
      "Native OpenSim tool execution is unavailable because this package was "
      "compiled without OpenSim support.");
#else
  assert_file_readable(setup_file, "OpenSim setup file");

  const std::string tool_key = to_lower(tool);

  int status = 0;
  std::string out_msg;
  std::string err_msg;

  try {
    if (tool_key == "ik") {
      OpenSim::InverseKinematicsTool tool_obj(setup_file);
      tool_obj.run();
      out_msg = "InverseKinematicsTool completed.";
    } else if (tool_key == "id") {
      OpenSim::InverseDynamicsTool tool_obj(setup_file);
      tool_obj.run();
      out_msg = "InverseDynamicsTool completed.";
    } else if (tool_key == "so") {
      OpenSim::AnalyzeTool tool_obj(setup_file);
      tool_obj.run();
      out_msg = "AnalyzeTool completed for static optimization workflow.";
    } else if (tool_key == "analyze") {
      OpenSim::AnalyzeTool tool_obj(setup_file);
      tool_obj.run();
      out_msg = "AnalyzeTool completed.";
    } else if (tool_key == "cmc") {
      OpenSim::CMCTool tool_obj(setup_file);
      tool_obj.run();
      out_msg = "CMCTool completed.";
    } else if (tool_key == "rra") {
      OpenSim::RRATool tool_obj(setup_file);
      tool_obj.run();
      out_msg = "RRATool completed.";
    } else {
      status = 1;
      err_msg = "Unsupported native tool type: " + tool +
                ". Supported values: ik, id, so, analyze, cmc, rra.";
    }
  } catch (const std::exception& e) {
    status = 1;
    err_msg = e.what();
  } catch (...) {
    status = 1;
    err_msg = "Unknown error while executing native OpenSim tool.";
  }

  return Rcpp::List::create(
      Rcpp::Named("status") = status,
      Rcpp::Named("stdout") =
          (out_msg.empty() ? Rcpp::CharacterVector() : Rcpp::CharacterVector::create(out_msg)),
      Rcpp::Named("stderr") =
          (err_msg.empty() ? Rcpp::CharacterVector() : Rcpp::CharacterVector::create(err_msg)));
#endif
}
