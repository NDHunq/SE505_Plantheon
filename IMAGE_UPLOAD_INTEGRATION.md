# Image Upload Integration - Chi Tiêu Form

## ✅ Completed Implementation

### 1. **Image Upload Methods** (lines 350-450 in chiTieu.dart)
- `_pickAndUploadImage(ImageSource source)`: Handles image selection and upload
  - Supports both Camera and Gallery sources
  - Compresses images (max 1920x1920, 85% quality)
  - Uploads to Supabase Storage bucket "uploads"
  - Shows success/error feedback via SnackBar
  
- `_showImageSourceDialog()`: Shows dialog to choose Camera or Gallery
  - Clean UI with icons for each option
  - Automatically closes after selection

### 2. **UI Components** (lines 1270-1355 in chiTieu.dart)
**Three states handled:**

#### State 1: Loading
- Shows `CircularProgressIndicator` when `_isUploadingImage == true`

#### State 2: Image Exists (attachedLink != null)
- Displays uploaded image with `Image.network()`
- Shows 200px height preview with loading/error states
- Two action buttons:
  - **"Đổi ảnh"**: Opens image source dialog to replace image
  - **"Xóa ảnh"**: Removes image (sets attachedLink to null)

#### State 3: No Image
- Shows **"Upload Ảnh"** button
- Opens image source dialog on tap

### 3. **Database Integration**

#### Loading Image (lines 145-148)
```dart
if (activity.attachedLink != null && activity.attachedLink!.isNotEmpty) {
  attachedLink = activity.attachedLink;
}
```

#### Saving Image (lines 620-622)
```dart
attachedLink: attachedLink != null && attachedLink!.isNotEmpty
    ? attachedLink
    : null,
```

### 4. **State Management**
- `String? attachedLink`: Stores Supabase public URL
- `bool _isUploadingImage`: Tracks upload progress

### 5. **Data Flow**
```
User clicks Upload → Shows Dialog → Selects Camera/Gallery
    ↓
Picks Image (with compression)
    ↓
Uploads to Supabase Storage (bucket: "uploads")
    ↓
Receives permanent public URL
    ↓
Updates attachedLink state → UI shows image
    ↓
On form submit → Saves to database field "attached_link"
    ↓
On edit → Loads from activity.attachedLink → Displays image
```

## 🔑 Key Features

✅ **Supabase Integration**: Uses existing SupabaseService
✅ **Web Compatible**: Uses Uint8List approach (no dart:io)
✅ **Permanent URLs**: Public bucket URLs never expire
✅ **Image Compression**: Optimizes file size before upload
✅ **Loading States**: Shows progress during upload
✅ **Error Handling**: Graceful fallbacks for network/load errors
✅ **Edit Support**: Loads existing images and allows replacement
✅ **Clean UI**: Matches existing form design with AppColors

## 📁 Files Modified

1. **lib/presentation/screens/diary/chiTieu.dart**
   - Added upload methods (_pickAndUploadImage, _showImageSourceDialog)
   - Added UI section for image display/upload
   - Added attachedLink to CreateActivityRequestModel
   - Added state variables (attachedLink, _isUploadingImage)
   - Added imports (image_picker, supabase_service)

2. **lib/data/models/activities_models.dart** (Already existed)
   - DayActivityDetailModel.attachedLink field ✅
   - CreateActivityRequestModel.attachedLink field ✅
   - Proper JSON mapping: 'attached_link' ✅

## 🧪 Testing Checklist

- [ ] Create new expense with image upload
- [ ] Verify image appears after upload
- [ ] Submit form and check database has attached_link URL
- [ ] Edit expense with image - verify image loads
- [ ] Change image in edit mode
- [ ] Delete image using "Xóa ảnh" button
- [ ] Test camera source (mobile only)
- [ ] Test gallery source
- [ ] Test on web platform
- [ ] Verify URL never expires (public bucket)

## 🎨 UI Layout

Located after "Người mua" field, before "Ghi chú" field:

```
┌─────────────────────────────────────┐
│ Hình ảnh đính kèm                   │
├─────────────────────────────────────┤
│ [Image Preview if exists]           │
│ ┌─────────────┬─────────────┐      │
│ │  Đổi ảnh    │   Xóa ảnh   │      │
│ └─────────────┴─────────────┘      │
│                                     │
│ OR                                  │
│                                     │
│ ┌───────────────────────────────┐  │
│ │ 📷  Upload Ảnh                │  │
│ └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## 🔗 Related Files

- `lib/core/services/supabase_service.dart` - Upload service
- `lib/presentation/screens/upload/file_upload_screen.dart` - Reference implementation
- `lib/data/models/activities_models.dart` - Data models
- `SUPABASE_STORAGE_GUIDE.md` - Setup guide

## 🚀 Ready to Use!

The integration is complete and ready for testing. All code compiles without errors and follows the existing pattern in the codebase.
