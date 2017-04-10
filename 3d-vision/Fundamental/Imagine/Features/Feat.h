// ===========================================================================
// Imagine++ Libraries
// Copyright (C) Imagine
// For detailed information: http://imagine.enpc.fr/software
// ===========================================================================

namespace Imagine {
	/// \addtogroup Features
	/// @{

	/// alias for feature point coordinates.
	typedef FVector<float,2> FloatPoint2;

	/// Feature point.
	/// Feature point.
	/// \param T FP descriptor type
	template <typename T>
	class FeaturePoint {
	public:
		/// FP descriptor type
		typedef T Desc;
		/// FP position
		FloatPoint2 pos;
		/// FP scale
		float scale;
		/// FP angle
		float angle;
		/// FP descriptor
		Desc desc;
		/// Read access: FP x position
		inline float x() const { return pos.x(); }
		/// Read access: FP y position
		inline float y() const { return pos.y(); }
	};

	/// Feature detector.
	/// Feature detector.
	/// \param T FeaturePoint type
	template <typename T>
	class FeatureDetector {
	public:
		/// FP type
		typedef T Feature;
		/// Run detection.
		/// Runs FP detection.
		/// \param I image on which detection is performed
		/// 
		/// \dontinclude Features/test/test.cpp \skip detection(
		/// \skipline runs detection
		virtual Array<T> run(const Image<byte>& I) const=0;
	};

	///@}
}
