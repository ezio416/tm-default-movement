// c 2024-03-15
// m 2024-03-15

uint16 GetMemberOffset(const string &in className, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::GetType(className);

    if (type is null)
        throw("Unable to find reflection info for " + className);

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    return member.Offset;
}

