import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/message_service.dart';
import '../../services/auth_service.dart';
import './widgets/conversation_list_widget.dart';
import './widgets/chat_screen_widget.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String? _selectedConversationId;

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () {
              // Mark all as read functionality
            },
            icon: CustomIconWidget(
              iconName: 'mark_email_read',
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return _buildEmptyState();
          }

          return _selectedConversationId == null
              ? ConversationListWidget(
                  conversations: conversations,
                  onConversationTap: (conversationId) {
                    setState(() {
                      _selectedConversationId = conversationId;
                    });
                  },
                )
              : ChatScreenWidget(
                  conversationId: _selectedConversationId!,
                  onBack: () {
                    setState(() {
                      _selectedConversationId = null;
                    });
                  },
                );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'Error loading messages',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'chat_bubble_outline',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 3.h),
          Text(
            'No Messages Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start a conversation by contacting item owners',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search-screen');
            },
            child: Text('Browse Items'),
          ),
        ],
      ),
    );
  }
}