/**********************************************************************

  Audacity: A Digital Audio Editor

  ExportUtils.h

  Dominic Mazzoni

  Vitaly Sverchinsky split from ExportPlugin.h

**********************************************************************/

#pragma once

#include "ExportTypes.h"
#include "ExportPlugin.h"

#include <functional>

class AudacityProject;
class TrackList;
class WaveTrack;

template<typename TrackType> struct TrackIterRange;

class IMPORT_EXPORT_API ExportUtils final
{
public:

    static TrackIterRange<const WaveTrack> FindExportWaveTracks(const TrackList& tracks, bool selectedOnly);

    static bool HasSelectedAudio(const AudacityProject& project);

    static ExportProcessor::Parameters ParametersFromEditor(const ExportOptionsEditor& editor);
};
