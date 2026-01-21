module Svc {
module Ccsds {

    @ Enum representing an error during framing/deframing in the CCSDS protocols
    enum FrameError: U8 {
        SP_INVALID_LENGTH = 0
        TC_INVALID_SCID = 1
        TC_INVALID_LENGTH = 2
        TC_INVALID_VCID = 3
        TC_INVALID_CRC = 4
    }

    # ------------------------------------------------
    # SpacePacket
    # ------------------------------------------------
    @ Describes the frame header format for the SpacePacket communications protocol
    struct SpacePacketHeader {
        packetIdentification: U16,   @< 3 bits PVN | 1 bit Pkt type | 1 bit Sec Hdr | 11 bit APID
        packetSequenceControl: U16,  @< 2 bits Sequence flags | 14 bits packet seq count (or name)
        packetDataLength: U16        @< 16 bits length
    }
    @ Masks and Offsets for deserializing individual sub-fields in SpacePacket headers
    module SpacePacketSubfields {
        # packetIdentification sub-fields     |--- 16 bits ---|
        constant PvnMask        = 0xE000  @< 0b1110000000000000
        constant PktTypeMask    = 0x1000  @< 0b0001000000000000
        constant SecHdrMask     = 0x0800  @< 0b0000100000000000
        constant ApidMask       = 0x07FF  @< 0b0000011111111111
        constant PvnOffset      = 13
        constant PktTypeOffset  = 12
        constant SecHdrOffset   = 11
        # packetSequenceControl sub-fields
        constant SeqFlagsMask   = 0xC000  @< 0b1100000000000000
        constant SeqCountMask   = 0x3FFF  @< 0b0011111111111111
        constant SeqFlagsOffset = 14
        # Widths
        constant ApidWidth      = 11
        constant SeqCountWidth  = 14
    }

    # ------------------------------------------------
    # TC
    # ------------------------------------------------
    @ Describes the frame header format for a Telecommand (TC) Transfer Frame
    struct TCHeader {
        flagsAndScId: U16,    @< 2 bits Frame V. | 1 bit bypass | 1 bit ctrl | 2 bit reserved | 10 bits spacecraft ID
        vcIdAndLength: U16,   @< 6 bits Virtual Channel ID | 10 bits Frame Length
        frameSequenceNum: U8  @< 8 bits Frame Sequence Number
    }
    @ Describes the frame trailer format for a Telecommand (TC) Transfer Frame
    struct TCTrailer {
        fecf: U16             @< 16 bit Frame Error Control Field (CRC16)
    }
    @ Masks and Offsets for deserializing individual sub-fields in TC headers
    module TCSubfields {
        # flagsAndScId sub-fields
        constant FrameVersionMask = 0xC000  @< 0b1100000000000000
        constant BypassFlagMask   = 0x2000  @< 0b0010000000000000
        constant ControlFlagMask  = 0x1000  @< 0b0001000000000000
        constant ReservedMask     = 0x0C00  @< 0b0000110000000000
        constant SpacecraftIdMask = 0x03FF  @< 0b0000001111111111
        constant BypassFlagOffset = 13
        # vcIdAndLength sub-fields
        constant VcIdMask         = 0xFC00  @< 0b1111110000000000
        constant FrameLengthMask  = 0x03FF  @< 0b0000001111111111
        constant VcIdOffset       = 10
    }

    # ------------------------------------------------
    # TM
    # ------------------------------------------------
    @ Describes the frame header format for a Telemetry (TM) Transfer Frame
    struct TMHeader {
        globalVcId: U16,         @< 2 bit Frame Version | 10 bit spacecraft ID | 3 bit virtual channel ID | 1 bit OCF flag
        masterFrameCount: U8,    @< 8 bit Master Channel Frame Count
        virtualFrameCount: U8,   @< 8 bit Virtual Channel Frame Count
        dataFieldStatus: U16     @< 1 bit 2nd Header | 1 bit sync | 1 bit pkt order | 2 bit seg len | 11 bit header ptr
    }
    @ Describes the frame trailer format for a Telemetry (TM) Transfer Frame
    struct TMTrailer {
        fecf: U16             @< 16 bit Frame Error Control Field (CRC16)
    }
    @ Offsets for serializing individual sub-fields in TM headers
    module TMSubfields {
        constant frameVersionOffset = 14
        constant spacecraftIdOffset = 4
        constant virtualChannelIdOffset = 1
        constant segLengthOffset = 11
    }

    # ------------------------------------------------
    # AOS
    # ------------------------------------------------
    @ Describes the frame header format for a Advanced Orbiting Systems (AOS) Space Data Link (SDL) Transfer Frame
    struct AOSHeader {
        globalVcId: U16,         @< 2 bit Frame Version | 8 least significant bits of spacecraft ID | 6 bit virtual channel ID
        frameCountAndSignaling: U32,  @< 24 bit virtual channel frame count
            @< 1 bit replay flag | 1 bit VC frame count cycle flag | 2 most significant bits of spacecraft ID | 4 bits VC frame count cycle
    }

    @ Offsets for serializing individual sub-fields in AOS headers
    module AOSHeaderSubfields {
        # globalVcId offsets
        constant frameVersionOffset = 14
        constant spacecraftIdLsbOffset = 6
        constant virtualChannelIdOffset = 0

        # signaling field offsets
        constant vcFrameCountOffset = 8
        constant replayFlagOffset = 7
        constant cycleCountFlagOffset = 6
        constant spacecraftIdMsbOffset = 4
    }

    @ Describes the header format for a Advanced Orbiting Systems (AOS) Space Data Link (SDL) multiplex protocol data unit (M_PDU)
    struct M_PDUHeader {
        firstHeaderPointer: U16     @< bytes to the header of the first new CCSDS Packet
    } default {
        firstHeaderPointer = 0xFFFF # Set first header pointer to all ones to mean no packet starts here (4.1.4.2.2.4)
    }

    @ Describes the frame trailer format for a Advanced Orbiting Systems (AOS) Space Data Link (SDL) Transfer Frame
    struct AOSTrailer {
        fecf: U16             @< 16 bit Frame Error Control Field (CRC16)
    }

    module PvnBitfield {
        constant SPP_MASK = 0x1 @< 1 << 0x0
        constant EPP_MASK = 0x8 @< 1 << 0x3
        constant VALID_MASK = SPP_MASK + EPP_MASK
    }

    @ Transfer Frame Version Numbers are 4 bits long
    @ CCSDS References add 1 to the binary value when counting versions in english (e.g. TM & TC are "version 1" but 0b00)
    @ Until the release of USLP, TFVN were 2 bits long
    @ With the addition of USLP two bits were added to the trailing end that serve as the 2 most significant bits
    @ (i.e. on the wire USLP sends 0b1100)
    @ See section 3.2.2.2 of USLP Overview (CCSDS 700.1-G-1),
    @ section 4.1.2.2.2 of AOS (CCSDS 732.0-B-5),
    @ section 4.3.2 of Space Data Link Protocol Summary (CCSDS 130.2-G-3),
    @ & table 3-1 in Overview of Space Comms Protocols (CCSDS 130.0-G-4)
    dictionary enum Tfvn : U8 {
        TM_TC         = 0x0   @< Telemetry and Telecommand SDLs
        AOS           = 0x1   @< Advanced Orbiting Systems SDL
        PROX_ONE      = 0x2   @< Proximity-1 SDL
        USLP          = 0x3   @< Unified Space Data Link Protocol
        INVALID_UNINITIALIZED         = 0x4  @< Anything equal or higher value is invalid and should not be used
    } default INVALID_UNINITIALIZED

    # CFDP
    # ------------------------------------------------ 
    enum CfdpStatus {
        SUCCESS @< CFDP operation has been succesfull
        ERROR @< Generic CFDP error return code
        PDU_METADATA_ERROR @< Invalid metadata PDU
        SHORT_PDU_ERROR @< PDU too short
        REC_PDU_FSIZE_MISMATCH_ERROR @< Receive PDU: EOF file size mismatch
        REC_PDU_BAD_EOF_ERROR @< Receive PDU: Invalid EOF packet
        SEND_PDU_NO_BUF_AVAIL_ERROR @< Send PDU: No send buffer available, throttling limit reached
        SEND_PDU_ERROR @< Send PDU: Send failed
    }

    enum CfdpFlow {
        NOT_FROZEN @< CFDP channel operations are executing nominally
        FROZEN @< CFDP channel operations are frozen
    }

    @ Values for CFDP file transfer class
    @
    @ The CFDP specification prescribes two classes/modes of file
    @ transfer protocol operation - unacknowledged/simple or
    @ acknowledged/reliable.
    @
    @ Defined per section 7.1 of CCSDS 727.0-B-5
    enum CfdpClass: U8 {
        CLASS_1 = 0 @< CFDP class 1 - Unreliable transfer
        CLASS_2 = 1 @< CFDP class 2 - Reliable transfer
    }
    @ Enum used to determine if a file should be kept or deleted after a CFDP transaction
    enum CfdpKeep: U8 {
        DELETE = 0 @< File will be deleted after the CFDP transaction
        KEEP = 1 @< File will be kept after the CFDP transaction
    }

    @ CFDP queue identifiers
    enum CfdpQueueId: U8 {
        PEND = 0, @< first one on this list is active
        TXA = 1
        TXW = 2
        RX = 3
        HIST = 4
        HIST_FREE = 5
        FREE = 6
        NUM = 7
    }

    @ CFDP File Directive Codes
    @ Blue Book section 5.2, table 5-4
    enum CfdpFileDirective: U8 {
        INVALID_MIN = 0  @< Minimum used to limit range
        END_OF_FILE = 4          @< End of File
        FIN = 5          @< Finished
        ACK = 6          @< Acknowledge
        METADATA = 7     @< Metadata
        NAK = 8          @< Negative Acknowledge
        PROMPT = 9       @< Prompt
        KEEP_ALIVE = 12  @< Keep Alive
        INVALID_MAX = 13 @< Maximum used to limit range
    }

    @ CFDP Condition Codes
    @ Blue Book section 5.2.2, table 5-5
    enum CfdpConditionCode: U8 {
        NO_ERROR = 0
        POS_ACK_LIMIT_REACHED = 1
        KEEP_ALIVE_LIMIT_REACHED = 2
        INVALID_TRANSMISSION_MODE = 3
        FILESTORE_REJECTION = 4
        FILE_CHECKSUM_FAILURE = 5
        FILE_SIZE_ERROR = 6
        NAK_LIMIT_REACHED = 7
        INACTIVITY_DETECTED = 8
        INVALID_FILE_STRUCTURE = 9
        CHECK_LIMIT_REACHED = 10
        UNSUPPORTED_CHECKSUM_TYPE = 11
        SUSPEND_REQUEST_RECEIVED = 14
        CANCEL_REQUEST_RECEIVED = 15
    }

    @ CFDP ACK Transaction Status
    @ Blue Book section 5.2.4, table 5-8
    enum CfdpAckTxnStatus: U8 {
        UNDEFINED = 0
        ACTIVE = 1
        TERMINATED = 2
        UNRECOGNIZED = 3
    }

    @ CFDP FIN Delivery Code
    @ Blue Book section 5.2.3, table 5-7
    enum CfdpFinDeliveryCode: U8 {
        COMPLETE = 0   @< Data complete
        INCOMPLETE = 1 @< Data incomplete
    }

    @ CFDP FIN File Status
    @ Blue Book section 5.2.3, table 5-7
    enum CfdpFinFileStatus: U8 {
        DISCARDED = 0           @< File discarded deliberately
        DISCARDED_FILESTORE = 1 @< File discarded due to filestore rejection
        RETAINED = 2            @< File retained successfully
        UNREPORTED = 3          @< File status unreported
    }

    @ CFDP Checksum Type
    @ Blue Book section 5.2.5, table 5-9
    enum CfdpChecksumType: U8 {
        MODULAR = 0       @< Modular checksum
        CRC_32 = 1        @< CRC-32 (not currently supported)
        NULL_CHECKSUM = 15 @< Null checksum
    }

    @ CFDP Record Continuation State
    @ Blue Book section 5.3, table 5-13
    enum CfdpRecordContinuationState: U8 {
        NO_START_NO_END = 0  @< No record start, no record end
        START_NO_END = 1     @< Record start, no record end
        END_NO_START = 2     @< Record end, no record start
        START_AND_END = 3    @< Record start and end
    }

    @ CFDP PDU Header
    @ Mirrors CF_CFDP_PduHeader_t structure with variable-length fields
    @ Uses F' serializable types which will handle encoding/decoding
    struct CfdpPduHeader {
        flags: U8, @< Bit-packed: bit 0 large file, bit 1 CRC, bit 2 txm mode, bit 3 direction, bit 4 PDU type, bits 5-7 version
        length: U16, @< PDU data length in octets (excludes header length)
        eidTsnLengths: U8, @< Bit-packed: bits 0-2 TSN length-1, bit 3 segment metadata flag, bits 4-6 EID length-1, bit 7 segmentation control
        sourceEid: CfdpEntityId, @< Source Entity ID
        transactionSeq: CfdpTransactionSeq, @< Transaction Sequence Number
        destinationEid: CfdpEntityId @< Destination Entity ID
    }

    @ CFDP File Directive Header
    struct CfdpFileDirectiveHeader {
        directiveCode: CfdpFileDirective @< File directive type
    }

    @ Metadata PDU Body (after directive header)
    @ Blue Book section 5.2.5, table 5-9
    struct CfdpMetadataPdu {
        segmentationControl: U8, @< Bit-packed: bits 0-3 checksum type, bits 4-6 reserved, bit 7 closure requested
        fileSize: U32, @< File size in octets
        sourceFilenameLength: U8, @< Length of source filename
        sourceFilename: [200] U8, @< Source filename bytes (max CfdpManagerMaxFileSize)
        destFilenameLength: U8, @< Length of destination filename
        destFilename: [200] U8 @< Destination filename bytes (max CfdpManagerMaxFileSize)
    }

    @ EOF PDU Body
    @ Blue Book section 5.2.2, table 5-6
    struct CfdpEofPdu {
        conditionCode: U8, @< Bit-packed: bits 0-3 spare, bits 4-7 condition code
        crc: U32, @< File checksum
        fileSize: U32, @< File size in octets
        tlvLength: U8, @< Length of TLV data
        tlvData: [256] U8 @< Optional TLV data
    }

    @ Finished PDU Body
    @ Blue Book section 5.2.3, table 5-7
    struct CfdpFinPdu {
        flags: U8, @< Bit-packed: bits 0-1 file status, bit 2 delivery code, bit 3 spare, bits 4-7 condition code
        tlvLength: U8, @< Length of TLV data
        tlvData: [256] U8 @< Optional TLV data
    }

    @ ACK PDU Body
    @ Blue Book section 5.2.4, table 5-8
    struct CfdpAckPdu {
        directiveAndSubtype: U8, @< Bit-packed: bits 0-3 directive subtype, bits 4-7 directive code being acknowledged
        ccAndTxnStatus: U8 @< Bit-packed: bits 0-1 transaction status, bits 2-3 spare, bits 4-7 condition code
    }

    @ NAK PDU Body
    @ Blue Book section 5.2.6, table 5-10
    struct CfdpNakPdu {
        scopeStart: U32, @< Start offset of NAK scope
        scopeEnd: U32, @< End offset of NAK scope
        numSegments: U8, @< Number of segment requests
        segmentRequests: [512] U8 @< Segment request list, each request is 8 bytes (2x U32)
    }

    @ File Data PDU (header + data)
    @ Blue Book section 5.3, table 5-13
    struct CfdpFileDataPdu {
        hasSegmentMetadata: U8, @< Flag: 1 if segment metadata present, 0 otherwise
        segmentMetadata: U8, @< Bit-packed: bits 0-5 segment metadata length, bits 6-7 record continuation state
        offset: U32, @< File offset for this data segment
        dataLength: U16, @< Length of actual file data
        fileData: [450] U8 @< Actual file data bytes (max CfdpMaxFileDataSize)
    }

    @< Structure for configuration parameters for a single CFDP channel
    struct CfdpChannelParams {
        ack_limit: U8 @< number of times to retry ACK (for ex, send FIN and wait for fin-ack)
        nack_limit: U8 @< number of times to retry NAK before giving up (resets on a single response
        ack_timer: U32 @< Acknowledge timer in seconds
        inactivity_timer: U32 @< Inactivity timer in seconds
        dequeue_enabled: Fw.Enabled @< if enabled, then the channel will make pending transactions active
        move_dir: string size CfdpManagerMaxFileSize @< Move directory if not empty
    }

    @< Struture for the configured array of CFDP channels
    array CfdpChannelArrayParams = [CfdpManagerNumChannels] CfdpChannelParams
}
}
