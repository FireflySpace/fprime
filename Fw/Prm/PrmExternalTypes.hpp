// ============================================================================
// @file   PrmExternalTypes.hpp
// @author Brian Campuzano
// @brief  Types for delegating parameter serialization and deserialization
// ============================================================================

#ifndef FW_EXTERNAL_PARAM_TYPES_HPP
#define FW_EXTERNAL_PARAM_TYPES_HPP

#include <Fw/Cmd/CmdResponseEnumAc.hpp>
#include <Fw/Prm/ParamValidEnumAc.hpp>
#include <config/FpConfig.hpp>
#include "PrmBuffer.hpp"

namespace Fw {

//! Fw::ParamExternalDelegate is used for parameters that are stored and managed
//! externally to the owning F' component.
//!
//! Fw::ParamExternalDelegate is an abstract base class that defines the interfaces
//! needed by the F' component to interact with the externally managed parameter(s)
class ParamExternalDelegate {
  public:
    //! Deserialize a parameter from a parameter buffer
    //!
    //! \param base_id: The component base ID of the parameter being deserialized
    //! \param local_id: The local parameter ID of the parameter being deserialized
    //! \param prmStat: In/out. Caller requests a validity (VALID); the delegate writes back the
    //!   resulting validity of the backing store
    //! \param buff: The buffer contained the serialized parameter
    //!
    //! \return: CmdResponse::OK if the update was accepted, VALIDATION_ERROR if rejected
    virtual CmdResponse deserializeParam(const FwPrmIdType base_id,
                                         const FwPrmIdType local_id,
                                         ParamValid& prmStat,
                                         SerialBufferBase& buff) = 0;

    //! Serialize a parameter into a parameter buffer
    //!
    //! \param base_id: The component base ID of the parameter being deserialized
    //! \param local_id: The local Parameter ID of the parameter to serialized
    //! \param buff: The buffer to serialize the parameter into
    //!
    //! \return: The status of the serialize operation
    virtual SerializeStatus serializeParam(const FwPrmIdType base_id,
                                           const FwPrmIdType local_id,
                                           SerialBufferBase& buff) const = 0;
};

}  // namespace Fw

#endif
