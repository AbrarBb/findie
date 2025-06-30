# Findie - Smart Lost & Found Platform

A modern Flutter + Supabase app for campus and local community lost & found items with AI-powered OCR text extraction and smart matching.

## 🚀 Features

### Core Functionality
- **Smart Item Posting**: Upload images with automatic OCR text extraction
- **Advanced Search**: Search by title, description, and extracted text from images
- **Real-time Messaging**: Anonymous chat between item owners and finders
- **Identity Verification**: Upload ID documents for verified user status
- **Auto-expiry**: Posts automatically expire after 14 days (extendable)

### AI/OCR Integration
- Automatic text extraction from uploaded images using Google ML Kit
- Smart tag generation from extracted text
- Enhanced search matching using OCR content
- Support for multiple image uploads per post

### User Experience
- **Modern UI**: Clean, responsive design with dark mode support
- **Smooth Animations**: Lottie animations and Flutter transitions
- **Real-time Updates**: Live messaging and notifications
- **Offline Support**: Cached data for better performance

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.6+**: Cross-platform mobile development
- **Riverpod**: State management
- **Sizer**: Responsive design
- **Google ML Kit**: On-device OCR
- **Lottie**: Animations
- **Cached Network Image**: Image caching

### Backend
- **Supabase**: Backend-as-a-Service
  - Authentication (Email/Password, OTP)
  - PostgreSQL Database with RLS
  - Real-time subscriptions
  - File storage
  - Edge Functions

### Database Schema
```sql
-- Users table
users (id, email, name, avatar_url, is_verified, created_at, metadata)

-- Posts table  
posts (id, user_id, title, description, category, building, image_urls, ocr_text, is_found, expires_at, created_at, tags, metadata)

-- Messages table
messages (id, from_user_id, to_user_id, post_id, message, timestamp, is_read)

-- Verifications table
verifications (id, user_id, id_image_url, extracted_name, extracted_dob, status, created_at)
```

## 📱 Screens

1. **Splash Screen**: Animated app intro with auth check
2. **Authentication**: Email/password and OTP login options
3. **Home Screen**: Browse lost/found items with filters
4. **Search Screen**: Advanced search with OCR text matching
5. **Post Item**: Upload images with OCR extraction and tagging
6. **Item Details**: Full item view with messaging
7. **Profile**: User info, verification, and posted items
8. **Messages**: Real-time chat conversations

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.6+)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd findie
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Supabase**
   - Create a new Supabase project
   - Run the migration files in `supabase/migrations/`
   - Deploy the Edge Functions in `supabase/functions/`
   - Update `lib/core/supabase_config.dart` with your project URL and keys

4. **Configure environment**
   - Update Supabase URL and keys in `supabase_config.dart`
   - Set up storage buckets: `post-images`, `avatars`, `verification-docs`

5. **Run the app**
```bash
flutter run
```

## 🔐 Authentication

The app supports multiple authentication methods:
- **Email/Password**: Traditional signup and login
- **OTP Login**: SMS-based authentication
- **Guest Mode**: Browse items without account (limited functionality)

## 🤖 AI Features

### OCR Text Extraction
- Automatic text extraction from uploaded images
- Support for multiple languages
- Confidence scoring for extracted text
- Smart tag generation from recognized content

### Smart Matching
- Search matches against both typed content and OCR text
- Fuzzy matching for better results
- Category and location-based filtering
- Full-text search with PostgreSQL

## 📊 Database Features

### Row Level Security (RLS)
- Secure data access based on user authentication
- Users can only modify their own content
- Public read access for browsing items

### Real-time Subscriptions
- Live message updates
- Real-time post notifications
- Instant search results

### Auto-expiry System
- Scheduled Edge Function runs daily
- Automatically removes expired posts
- Optional email notifications for expiring items

## 🎨 UI/UX Design

### Design Principles
- **Material Design 3**: Modern, accessible components
- **Glassmorphism**: Subtle transparency effects
- **Responsive**: Adapts to different screen sizes
- **Dark Mode**: Full dark theme support

### Animations
- Smooth page transitions
- Loading states with Lottie animations
- Micro-interactions for better UX
- Hero animations for image viewing

## 🔒 Security Features

### Data Protection
- Row Level Security on all tables
- Secure file upload with signed URLs
- Input validation and sanitization
- Rate limiting on API endpoints

### Privacy
- Anonymous messaging system
- Optional identity verification
- Secure document storage
- GDPR-compliant data handling

## 📈 Performance

### Optimization
- Image compression and caching
- Lazy loading for large lists
- Efficient database queries with indexes
- Offline-first architecture

### Monitoring
- Error tracking and reporting
- Performance metrics
- User analytics (privacy-compliant)
- Real-time monitoring

## 🚀 Deployment

### Mobile App
```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release
```

### Backend
- Supabase handles all backend deployment
- Edge Functions auto-deploy from Git
- Database migrations via Supabase CLI

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Check the documentation
- Contact the development team

---

**Findie** - Lost it? Findie it! 🔍